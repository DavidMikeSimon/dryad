class Dryad
  def build_document(&block)
    builder = DryadDocumentBuilder.new
    return builder.send(:run!, &block)
  end

  private
end

class DryadDocumentBuilder
  def initialize
    @stack = []
  end

  def raw_text!(text)
    @stack.last.push(text.strip)
  end

  def tag!(sym)
    contents = run! do
      yield if block_given?
    end
    if contents != ""
      raw_text! "<#{sym.to_s}>" + contents + "</#{sym.to_s}>"
    else
      raw_text! "<#{sym.to_s}/>"
    end
  end
  
  private

  def run!(&block)
    @stack.push []
    instance_eval &block
    return @stack.pop.join
  end
end
