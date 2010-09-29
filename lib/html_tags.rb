module Dryad
  HtmlTags = proc do
    def html(&block)
      raw_tag! :html, attributes, &block
    end

    def body(&block)
      raw_tag! :body, attributes, &block
    end

    def p(subject = nil, &block)
      block ||= proc { v subject }
      raw_tag! :p, attributes, &block
    end
    
    def b(subject = nil, &block)
      block ||= proc { v subject }
      raw_tag! :b, attributes, &block
    end

    def hr
      raw_tag! :hr, attributes
    end
  end
end
