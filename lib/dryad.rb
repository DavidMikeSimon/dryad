class Dryad
  def run(&block)
    @stack = []
    instance_eval &block
  end

  private
  
  def tag!(sym)
    @stack.push []
    yield if block_given?
    contents = @stack.pop.join
    if contents != ""
      return "<#{sym.to_s}>" + contents + "</#{sym.to_s}>"
    else
      return "<#{sym.to_s}/>"
    end
  end

  def raw_text!(text)
    @stack.last.push(text.strip)
  end
end
