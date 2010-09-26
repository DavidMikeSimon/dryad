require 'exceptions'

module Dryad
  class TagLibrary
    def initialize
      @blocks = []
    end

    def output(target, &block)
      builder = DocumentBuilder.new(target)
      @blocks.each do |b|
        builder.instance_eval &b
      end
      builder.send(:run!, &block)
    end

    def add(&block)
      @blocks.push block
    end
  end

  class DocumentBuilder
    def initialize(io)
      @io = io
    end

    def raw_text!(text)
      @io.write(text.strip)
    end

    # TODO Add a text! method that escapes its input

    def raw_tag!(sym, params = {}, &block)
      param_str = ""
      if params.size > 0
        # TODO Escape values
        param_str = " " + params.map{|k,v| "#{k}=\"#{v}\""}.join(" ")
      end

      if block
        raw_text! "<#{sym.to_s}#{param_str}>"
        run! &block
        raw_text! "</#{sym.to_s}>"
      else
        raw_text! "<#{sym.to_s}#{param_str}/>"
      end
    end

    private

    def run!(input_source = nil, &block)
      # Cloning so that tags redefined in block can 'super' to the original
      self.clone.instance_eval(&block)
    end

    def method_missing(symbol)
      raise NoSuchTagError.new(symbol)
    end
  end
end
