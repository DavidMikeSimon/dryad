require 'default_tags'
require 'exceptions'
require 'near_miss_suggestions'

module Dryad
  class TagLibrary
    def initialize
      @tag_def_blocks = []
      add &DefaultTags
    end
 
    def output(target, &block)
      writer = DocumentWriter.new(target)
      @tag_def_blocks.each do |b|
        writer.run :leave_on_stack => true, &b
      end
      writer.run &block
    end

    def add(&block)
      raise DryadError.new("TagLibrary.add must be given a block") unless block
      @tag_def_blocks.push block
    end
  end

  private

  class DocumentWriter
    def initialize(io)
      @io = io
      @context_stack = []

      context_base = Class.new
      context_base.instance_eval &ContextBaseMethods
      @context_stack.push context_base
      writer = self
      @context_stack.last.instance_eval { @_writer = writer }
    end

    def write(str)
      @io.write str
    end

    def run(options = {}, &block)
      new_context = Class.new(@context_stack.last)
      @context_stack.last.instance_variables.each do |varname|
        value = @context_stack.last.instance_variable_get(varname.to_sym)
        if !(value.is_a?(FalseClass) || value.is_a?(TrueClass) || value.is_a?(NilClass))
          value = value.clone
        end
        new_context.instance_variable_set(varname.to_sym, value)
      end
      @context_stack.push new_context

      begin
        @context_stack.last.instance_eval &block
      ensure
        unless options[:leave_on_stack]
          @context_stack.pop
        end
      end
    end

    ContextBaseMethods = proc do
      def attributes
        @_attributes || AttributesHash.new
      end

      def raw_text!(str)
        @_writer.write str
      end

      # Runs the given code in a new sub-context
      def run(&block)
        @_writer.run &block
      end

      private

      def process_tag_arguments(args)
        new_args = []
        attrs = AttributesHash.new

        auto_classes = []
        auto_id = nil
        args.each do |arg|
          if arg.is_a?(Hash)
            attrs.merge! arg 
          elsif arg.is_a?(Symbol) and ["!", "="].include?(arg.to_s[-1,1])
            case arg.to_s[-1,1]
            when "!"
              auto_classes << arg.to_s.chop
            when "="
              raise DryadError.new("Cannot give multiple automatic id symbols to the same tag") if auto_id
              auto_id = arg.to_s.chop
            end
          else
            new_args.push arg
          end
        end

        auto_classes.each do |c|
          attrs.merge!({:class => c})
        end
        attrs[:id] = auto_id if auto_id

        @_attributes = attrs
        return new_args
      end
    
#      def singleton_method_added(symbol)
#        return if @_method_being_wrapped || symbol == :singleton_method_added
#        @_method_being_wrapped = true
#
#        begin
#          wrapped_method = method(symbol) 
#          singleton_class = lambda { class << self; self; end }.call
#          singleton_class.instance_eval do
#            define_method symbol do |*args, &block|
#              run do
#                new_args = process_tag_arguments(args)
#                wrapped_method.call(*new_args, &block)
#              end
#            end
#          end
#        ensure
#          @_method_being_wrapped = nil
#        end
#      end

      def method_missing(symbol, *args)
        begin
          super
        rescue NameError => e
          NearMissSuggestions::reraise_with_suggestions(e, self)
        end
      end
    end
  end

  # TODO: Prevent AttributesHash from being modified in place after being setup
  class AttributesHash < Hash
    def initialize(orig_hash = nil)
      replace(orig_hash) if orig_hash
    end

    def +(other_hash)
      return merge(other_hash)
    end

    def merge!(other_hash)
      other_hash.each do |k,v|
        if k == :class and self.has_key?(k)
          self[k] = self[k] + " #{v}"
        else
          self[k] = v
        end
      end
    end

    def update(other_hash)
      merge!(other_hash)
    end

    def merge(other_hash)
      c = self.clone
      c.merge!(other_hash)
      return c
    end
  end
end
