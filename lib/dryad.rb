require 'exceptions'

module Dryad
  class TagLibrary
    def initialize
      @tag_def_blocks = []
    end

    def output(target, &block)
      builder = DocumentBuilder.new(target)
      @tag_def_blocks.each do |b|
        builder.instance_eval &b
      end
      builder.send(:run!, &block)
    end

    def add(&block)
      if block
        @tag_def_blocks.push block
      else
        raise DryadError.new("TagLibrary.add must be given a block")
      end
    end

    def add_module(tag_module)
      @tag_def_blocks.push proc { extend tag_module }
    end
  end

  class DocumentBuilder
    def initialize(io)
      @io = io
    end

    def raw_text!(str)
      @io.write str
    end

    # TODO Make this method escape its input 
    def text!(str)
      raw_text! str
    end

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
      # Cloning so that tags redefined in block can 'super' back to the original
      self.clone.instance_eval(&block)
    end

    def method_missing(symbol)
      # TODO Raise a different error if the symbol ends with ! or ?, since then it can't be a tag name
      raise NoSuchTagError.new(symbol)
    end
  end
end
