module Dryad
  class DryadException < Exception
  end

  class NoSuchTagException < Exception
    attr_reader :tag_name
   
    def initialize(tag_sym)
      @tag_name = tag_sym.to_s
    end

    def to_s
      "There's no tag named '#{@tag_name}'"
    end
  end
end
