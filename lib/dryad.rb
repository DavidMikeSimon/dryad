require 'cgi'

require 'default_tags'
require 'exceptions'

module Dryad
  class TagLibrary
    def initialize
      @tag_def_blocks = []
      add &DefaultTags
    end
 
    def output(target, &block)
      builder = DocumentBuilder.new(target)
      @tag_def_blocks.each do |b|
        builder = builder.send(:permanent_clone)
        builder.instance_eval &b
      end
      builder.run! &block
    end

    def add(&block)
      if block
        @tag_def_blocks.push block
      else
        raise DryadError.new("TagLibrary.add must be given a block")
      end
    end
  end

  class DocumentBuilder
    def initialize(io)
      @io = io
      @attrs_stack = []
      @clones_stack = [self]
    end

    def raw_text!(str)
      @io.write str
    end

    def raw_tag!(sym, params = {}, &block)
      param_str = ""
      if params.size > 0
        param_str = " " + params.map{|k,v| "#{k}=\"#{CGI::escapeHTML(v)}\""}.join(" ")
      end

      if block
        raw_text! "<#{sym.to_s}#{param_str}>"
        run! &block
        raw_text! "</#{sym.to_s}>"
      else
        raw_text! "<#{sym.to_s}#{param_str}/>"
      end
    end

    def text!(str)
      raw_text! CGI::escapeHTML(str)
    end

    # Runs the given code in a new sub-context
    # This lets you safely redefine methods inside the block; they'll be restored afterwords
    def run!(&block)
      if @clones_stack.last != self
        @clones_stack.last.run!(&block)
      else
        c = clone
        @clones_stack.push(c)
        begin
          c.instance_eval &block
        ensure
          @clones_stack.pop
        end
      end
    end

    def attributes
      @attrs_stack.last or AttributesHash.new
    end

    private

    def permanent_clone
      # Called permanent because this clone needs to exist for as long as any clones of this DocumentBuilder are in use
      c = clone
      @clones_stack.push(c)
      return c
    end

    # TODO: Check against AttributesHash pollution
    def clone
      super
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

    def singleton_method_added(symbol)
      return if @method_being_wrapped # Otherwise we'll try to wrap the wrapper recursively
      @method_being_wrapped = true

      # We need to use this technique reach the wrapped method from here, super won't work without cloning
      sc = lambda { class << self; self; end }.call
      wrapped_method = sc.instance_method(symbol).bind(self)

      # Define a wrapper method that mediates input to the actual tag method
      sc.send(:define_method, symbol) do |*args, &block|
        run! do # The major advatange of using run! here is that if we're not at the top of the clone stack, it moves us there
          new_args = []
          attrs = nil
          while args.size > 0
            arg = args.shift
            if arg.is_a?(Hash)
              attrs = AttributesHash.new if attrs.nil?
              attrs.merge!(arg)
            else
              new_args.push arg
            end
          end

          @attrs_stack.push(attrs) if attrs
          begin
            wrapped_method.call(*new_args, &block)
          ensure
            @attrs_stack.pop if attrs
          end
        end
      end

      @method_being_wrapped = false
    end

    def method_missing(symbol, *args)
      # TODO Raise a different error if the symbol ends with ! or ? or =, since then it can't be a tag name
      raise NoSuchTagError.new(symbol)
    end
  end
end
