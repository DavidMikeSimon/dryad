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
        run &block
        raw_text! "</#{sym.to_s}>"
      else
        raw_text! "<#{sym.to_s}#{attr_str}/>"
      end
    end

    # V is for "view", by default it just displays the given thing as a safely escaped string
    def v(subject)
      raw_text! CGI::escapeHTML(subject.to_s)
    end
  end
end
