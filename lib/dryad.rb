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

  def tag!(sym, params = {})
    param_str = ""
    if params.size > 0
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
