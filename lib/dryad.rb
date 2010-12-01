require 'exceptions'
require 'near_miss_suggestions'

require 'set'

module Dryad
  class Dryad
    def initialize
      @writer = DocumentWriter.new
    end
 
    def output(target, &block)
      @writer.run :output => target, &block
    end

    def add(&block)
      raise ArgumentError.new("Dryad.add must be given a block") unless block
      @writer.run :leave_on_stack => true, &block
    end

    def add_module(mod)
      add do
        include mod
      end
    end
  end

  private
  
  class Context
    def initialize(parent_context = nil)
      @_content_blocks = parent_context ? parent_context.send(:instance_variable_get, :@_content_blocks) : {}
    end

    def raw_text(str)
      self.class.cur_writer.write str
    end

    # Runs the given block in a new sub-context
    def run(&block)
      self.class.cur_writer.run &block
    end

    # Runs the given method in a new sub-context, first executing the given block in that context
    def running(symbol, *args, &block)
      run do
        cur_writer.eval_with_dummy_output &block
        send(symbol, *args)
      end
    end

    # Specifies a block for "running" to give its method access to
    def content(symbol = :content, &block)
      @_content_blocks[symbol] = block
    end

    def attributes
      @_attributes || AttributesHash.new
    end

    private

    def self.subclass_for_writer(writer)
      subclass = Class.new(self)
      subclass.class_eval do
        singleton = lambda { class << self; self; end }.call
        singleton.send(:define_method, :cur_writer) do
          return writer
        end
      end
      return subclass
    end

    def self.cur_writer
      raise InternalError.new("No specific cur_writer defined in Context!")
    end

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

      @_attributes.freeze
      return new_args
    end
 
    # The real method_missing for regular failed method calls.
    # Overridden to use NearMissSuggestions to flag spelling errors in tag names
    def method_missing(symbol, *args, &block)
      super
    rescue NameError => e
      NearMissSuggestions::reraise_with_suggestions(e, self, $@)
    end

    # The evil sneaky method_missing for the silly hack used for hybrid evaluation.
    # Method definitions will be trapped by method_added and appropriately wrapped
    # Any attempts to call instance methods will be forwarded to cur_writer
    def self.method_missing(symbol, *args, &block)
      cur_writer.cur_context.send(symbol, *args, &block)
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
        new_args = process_tag_arguments(args)
        
        cb = @_content_blocks
        default_block = block
        if not default_block
          default_block = cb.delete(:content)
        end
        # Only delete the content_blocks entry if the wrapped definition actually yields
        # FIXME - This does NOT solve the too-deep targetting problem
#        block = proc do |arg|
#          if arg
#            cb.delete(arg).call
#          else
#            default_block.call
#          end
#        end
        tag_def.bind(self).call(*new_args, &block)
        return nil
      end

      # If a method by this name already exists in Kernel (p, for example), then
      # we also need to trap class-level calls so hybrid evaluation works as for other methods
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

  class DummyIO
    def write(s)
      raise WritingOutOfContextError.new("No output target available")
    end
  end

  class DocumentWriter
    def initialize
      @output_stack = [DummyIO.new]

      context_class = Context.subclass_for_writer(self)
      @context_stack = [context_class.new]
    end

    def write(str)
      @output_stack.last.write str
    end

    def run(options = {}, &block)
      @output_stack.push(options[:output] || DummyIO.new) if options.has_key?(:output)
      
      new_context = cur_context.class.subclass_for_writer(self).new(cur_context)
      @context_stack.push new_context
      begin
        new_context.class.class_eval &block
      ensure
        @context_stack.pop unless options[:leave_on_stack]
        @output_stack.pop if options.has_key?(:output)
      end
    end

    def eval_with_dummy_output(&block)
      @output_stack.push DummyIO.new
      cur_context.class.class_eval &block
    ensure
      @output_stack.pop
    end

    def cur_context
      @context_stack.last
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
      c = AttributesHash.new(self)
      c.merge!(other_hash)
      return c
    end
  end
end
