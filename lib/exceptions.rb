module Dryad
  class DryadError < RuntimeError
  end

  class NoSuchTagError < DryadError
    attr_reader :tag_name
   
    def initialize(tag_sym)
      @tag_name = tag_sym.to_s
    end

    def to_s
      "There's no tag named '#{@tag_name}'"
    end
  end
end
