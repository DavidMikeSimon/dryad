module Dryad 
  DefaultTags = proc do
    # V is for "view", by default it just displays the given thing as a string
    def v(subject)
      text! subject.to_s
    end
  end
end
