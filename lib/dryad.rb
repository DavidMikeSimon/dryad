class Dryad
  def tag!(sym)
    return "<#{sym.to_s}>" + yield + "</#{sym.to_s}>"
  end

  def run(&block)
    instance_eval &block
  end
end
