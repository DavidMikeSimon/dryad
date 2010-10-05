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
  
  class Context
    def initialize(writer)
      # Using funny underscored name to avoid clashing with user instance variables
      @_writer = writer
    end

    def raw_text!(str)
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
            raise DryadError.new("Cannot give multiple automatic id symbols to the same tag") if auto_id
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
 
    # The real method_missing, for when the user calls a non-existant method
    # This version uses NearMissSuggestions to notice spelling errors in tag names
    def method_missing(symbol, *args)
      begin
        super
      rescue NameError => e
        NearMissSuggestions::reraise_with_suggestions(e, self)
      end
    end

    # The evil sneaky method_missing for the silly hack used by dryad for delayed execution
    # Method definitions will work as normal, but any attempts to call methods will just be recorded
    @@recording = nil
    def self.method_missing(symbol, *args, &block)
      @@recording << [symbol, args, block]
    end
   
    def self.begin_capture
      @@recording = []
    end

    def self.end_capture
      r = @@recording
      @@recording = nil
      return r
    end

    def replay_capture(statements)
      statements.each do |statement|
        symbol, args, block = statement
        new_args = process_tag_arguments(args)
        send(symbol, *new_args, &block)
      end
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
        value = value.clone unless [FalseClass, TrueClass. NilClass].include?(value.class)
        new_context.instance_variable_set(varname.to_sym, value)
      end

      @context_stack.push new_context
      begin
        @context_stack.last.class.send(:begin_capture)
        @context_stack.last.class.class_eval &block
        statements = @context_stack.last.class.send(:end_capture)
        @context_stack.last.send(:replay_capture, statements)
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
