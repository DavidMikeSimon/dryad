class Dryad
  def tag!(sym)
    contents = ""
    if block_given?
      contents = yield.to_s.strip
    end
    if contents != ""
      return "<#{sym.to_s}>" + contents + "</#{sym.to_s}>"
    else
      return "<#{sym.to_s}/>"
    end
  end

  def run(&block)
    instance_eval &block
  end
end
