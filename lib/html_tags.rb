module Dryad
  module HtmlTags
    def html(&block)
      raw_tag :html, attributes, &block
    end

    def body(&block)
      raw_tag :body, attributes, &block
    end

    def p(subject = nil, &block)
      raw_tag :p, attributes do
        v subject if subject
        yield
      end
    end
    
    def b(subject = nil, &block)
      raw_tag :b, attributes do
        v subject if subject
        yield
      end
    end

    def hr
      raw_tag :hr, attributes
    end
  end
end
