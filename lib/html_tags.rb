module HtmlTags 
  # Convenience tag: v is for "view", by default it just displays the given thing as a string
  def v(str = "")
    text! str.to_s
  end

  def html(&block)
    raw_tag! :html, &block
  end

  def head(&block)
    raw_tag! :head, &block
  end
  
  def body(params = {}, &block)
    raw_tag! :body, params, &block
  end

  def p(params = {}, &block)
    raw_tag! :p, params, &block
  end
  
  def b(params = {}, &block)
    raw_tag! :b, params, &block
  end

  def hr(params = {})
    raw_tag! :hr, params
  end
end
