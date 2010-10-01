require 'cgi'

module Dryad 
  DefaultTags = proc do
    def raw_tag(sym, &block)
      attrs = attributes
      attr_str = ""
      if attrs.size > 0
        attr_str = " " + attrs.map{|k,v| "#{k}=\"#{CGI::escapeHTML(v)}\""}.join(" ")
      end

      if block
        raw_text! "<#{sym.to_s}#{attr_str}>"
        run! &block
        raw_text! "</#{sym.to_s}>"
      else
        raw_text! "<#{sym.to_s}#{attr_str}/>"
      end
    end

    def text(str)
      raw_text! CGI::escapeHTML(str)
    end

    # V is for "view", by default it just displays the given thing as a string
    def v(subject)
      text subject.to_s
    end
  end
end
