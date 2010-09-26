require 'exceptions'

module Dryad
  class TagLibrary
    def initialize
      @tag_defs = {}
    end

    def output(&block)
      builder = DocumentBuilder.new(self)
      return builder.send(:run!, &block)
    end

    def define_tag(sym, &block)
      @tag_defs[sym.to_sym] = block
    end

    def get_tag(sym)
      @tag_defs[sym] or raise NoSuchTagException.new(sym)
    end
  end

  class DocumentBuilder
    def initialize(taglib)
      @taglib = taglib
      @output_stack = []
      @argument_stack = []
    end

    def method_missing(symbol, *params, &content_block)
      block = @taglib.get_tag(symbol)
      @argument_stack.push(Arguments.new(params, content_block))
      instance_eval(&block)
      @argument_stack.pop
    end

    def content_block!
      return @argument_stack.last.block
    end

    def raw_text!(text)
      @output_stack.last.push(text.strip)
    end

    # TODO Add a text! method that escapes its input

    def raw_tag!(sym, params = {})
      param_str = ""
      if params.size > 0
        # TODO Escape values
        param_str = " " + params.map{|k,v| "#{k}=\"#{v}\""}.join(" ")
      end

      contents = run! { yield if block_given? }
      if contents != ""
        raw_text! "<#{sym.to_s}#{param_str}>" + contents + "</#{sym.to_s}>"
      else
        raw_text! "<#{sym.to_s}#{param_str}/>"
      end
    end

    private

    def run!(input_source = nil, &block)
      @output_stack.push []
      instance_eval(&block)
      return @output_stack.pop.join
    end

    class Arguments
      attr_reader :params
      attr_reader :block

      def initialize(params, block)
        @params = params
        @block = block
      end
    end
  end
end
