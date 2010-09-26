class Dryad
  def initialize
    @tag_defs = {}
  end

  def build_document(&block)
    builder = DryadDocumentBuilder.new(self)
    return builder.send(:run!, &block)
  end

  def define_tag(sym, &block)
    @tag_defs[sym.to_sym] = block
  end

  private

  def execute_tag(sym, builder)
    block = @tag_defs[sym]
    return builder.send(:run!, &block)
  end
end

class DryadDocumentBuilder
  def initialize(dryad)
    @dryad = dryad
    @stack = []
  end

  def method_missing(symbol, *params)
    raw_text! @dryad.send(:execute_tag, symbol, self)
  end

  def raw_text!(text)
    @stack.last.push(text.strip)
  end

  # TODO Add a text! method that escapes its input

  def tag!(sym, params = {})
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

  def run!(&block)
    @stack.push []
    instance_eval &block
    return @stack.pop.join
  end
end
