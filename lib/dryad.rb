require 'default_tags'
require 'exceptions'
require 'near_miss_suggestions'
require 'set'

module Dryad
  class Dryad
    def initialize
      @tag_def_blocks = []
      add_module DefaultTags
    end
 
    def output(target, &block)
      writer = DocumentWriter.new(target)
      @tag_def_blocks.each do |b|
        writer.run :leave_on_stack => true, &b
      end
      writer.run &block
    end

    def add(&block)
      raise ArgumentError.new("Dryad.add must be given a block") unless block
      @tag_def_blocks.push block
    end

    def add_module(mod)
      add do
        include mod
      end
    end
  end

  private
  
  class Context
    def initialize(writer)
      # Using funny underscored names to avoid clashing with user instance variables
      @_writer = writer
    end

    def raw_text(str)
      @_writer.write str
    end

    # Runs the given block in a new sub-context
    def run(&block)
      @_writer.run &block
    end

    def attributes
      @_attributes || AttributesHash.new
    end

    private

    def process_tag_arguments(args)
      @_attributes = AttributesHash.new
      new_args = []

      auto_classes = []
      auto_id = nil
      args.each do |arg|
        if arg.is_a?(Hash)
          @_attributes.merge! arg 
        elsif arg.is_a?(Symbol) and ["!", "="].include?(arg.to_s[-1,1])
          case arg.to_s[-1,1]
          when "!"
            auto_classes << arg.to_s.chop
          when "="
            raise MultipleIdsError.new("Cannot give multiple automatic id symbols to the same tag") if auto_id
            auto_id = arg.to_s.chop
          end
        else
          new_args.push arg
        end
      end

      auto_classes.each do |c|
        @_attributes.merge!({:class => c})
      end
      @_attributes[:id] = auto_id if auto_id

      return new_args
    end
 
    # The real method_missing for regular method calls
    # Overridden to use NearMissSuggestions to notice spelling errors in tag names
    def method_missing(symbol, *args, &block)
      super
    rescue NameError => e
      NearMissSuggestions::reraise_with_suggestions(e, self, $@)
    end

    # The evil sneaky method_missing for the silly hack used for delayed execution in class_eval
    # Method definitions will be trapped by method_added and appropriately wrapped
    # Any attempts to call instance methods will be forwarded to @@instance_method_target
    @@instance_method_targets = []
    def self.method_missing(symbol, *args, &block)
      @@instance_method_targets.last << [symbol, args, block]
    end
 
    def self.capture(&block)
      @@instance_method_targets.push []
      class_eval &block
      return @@instance_method_targets.last
    ensure
      @@instance_method_targets.pop
    end

    def replay(statements)
      statements.each do |statement|
        symbol, args, block = statement
        send(symbol, *args, &block)
      end
    end

    def self.include(mod)
      super
      mod.instance_methods.each do |name|
        method_added(name.to_sym)
      end
    end

    @@wrapping_method = false
    @@kernel_methods = Set.new(Kernel.methods.map(&:to_sym))
    def self.method_added(symbol)
      return if @@wrapping_method
      @@wrapping_method = true
      
      # Wrap the method that was defined with some convienent argument-preprocessing
      tag_def = instance_method(symbol)
      define_method symbol do |*args, &block|
        tag_def.bind(self).call(*process_tag_arguments(args), &block)
      end

      # If a method by this name already exists in Kernel (p, for example), then
      # we need to trap class-level calls for when we're recording later
      if @@kernel_methods.include?(symbol)
        singleton_class = lambda { class << self; self; end }.call
        singleton_class.send(:define_method, symbol) do |*args, &block|
          method_missing(symbol, *args, &block)
        end
      end
    ensure
      @@wrapping_method = false
    end
  end

  class DocumentWriter
    def initialize(io)
      @io = io
      @context_stack = [Context.new(self)]
    end

    def write(str)
      @io.write str
    end

    def run(options = {}, &block)
      new_context = Class.new(@context_stack.last.class).new(self)
      @context_stack.last.instance_variables.each do |varname|
        next if varname[0,2] == "@_" # Dryad internals, not to be automatically copied
        value = @context_stack.last.instance_variable_get(varname.to_sym)
        new_context.instance_variable_set(varname.to_sym, value)
      end

      @context_stack.push new_context
      begin
        statements = @context_stack.last.class.send(:capture, &block)
        @context_stack.last.send(:replay, statements)
      ensure
        @context_stack.pop unless options[:leave_on_stack]
      end
    end
  end

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
