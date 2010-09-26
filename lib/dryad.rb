require 'exceptions'

module Dryad
  class TagLibrary
    def initialize
      @blocks = []
    end

    def output(&block)
      builder = DocumentBuilder.new(self)
      @blocks.each do |b|
        builder.instance_eval &b
      end
      return builder.send(:run!, &block)
    end

    def add(&block)
      @blocks.push block
    end
  end

  class DocumentBuilder
    def initialize(taglib)
      @taglib = taglib
      @output_stack = []
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
  end
end
