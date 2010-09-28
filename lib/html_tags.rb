module Dryad
  HtmlTags = proc do
    def html(args = {}, &block)
      raw_tag! :html, args, &block
    end

    def body(args = {}, &block)
      raw_tag! :body, args, &block
    end

    def p(subject = nil, args = {}, &block)
      block ||= proc { v subject }
      raw_tag! :p, args, &block
    end

    def b(subject = nil, args = {}, &block)
      block ||= proc { v subject }
      raw_tag! :b, args, &block
    end

    def hr(args = {})
      raw_tag! :hr, args
    end
  end
end
