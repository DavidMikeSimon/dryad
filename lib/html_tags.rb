module HtmlTags 
  def html(&block)
    raw_tag! :html, &block
  end
 
  def body(params = {}, &block)
    raw_tag! :body, params, &block
  end

  def p(params = {}, &block)
    block ||= proc { v(params) }
    raw_tag! :p, {}, &block
  end
  
  def b(params = {}, &block)
    block ||= proc { v(params) }
    raw_tag! :b, {}, &block
  end

  def hr(params = {})
    raw_tag! :hr, params
  end
end
