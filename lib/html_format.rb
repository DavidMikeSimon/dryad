require 'cgi'

module Dryad 
  module HtmlFormat
    def raw_tag(sym, &block)
      attr_str = ""
      if attributes.size > 0
        attr_str = " " + attributes.map{|k,v| "#{k}=\"#{CGI::escapeHTML(v)}\""}.join(" ")
      end

      if block
        raw_text "<#{sym.to_s}#{attr_str}>"
        run &block
        raw_text "</#{sym.to_s}>"
      else
        raw_text "<#{sym.to_s}#{attr_str}/>"
      end
    end

    # V is for "view", by default it just displays the given thing as a safely escaped string
    def v(subject)
      raw_text CGI::escapeHTML(subject.to_s)
    end
  end
end