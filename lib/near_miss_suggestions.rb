module Dryad
  module NearMissSuggestions
    def self.reraise_with_suggestions(e, obj, callstack)
      message = e.message

      unless message.include?("Perhaps you meant")
        # Find any methods that are only one character off from the given incorrect method
        suggestions = []

        invalid_semis = string_to_semis(e.name.to_s)
        obj.methods.reject{|m| Object.methods.include?(m)}.each do |m|
          got_match = false
          string_to_semis(m).each do |m_semi|
            invalid_semis.each do |i_semi|
              if m_semi == i_semi
                suggestions << m
                got_match = true
                break
              end
            end
            break if got_match
          end
        end

        if suggestions.size > 0
          suggestions.sort!
          message << "\nPerhaps you meant one of these methods:\n "
          message << suggestions.join("\n ")
        end
      end

      raise NameError.new(nil, e.name), message, callstack
    end

    private

    def self.string_to_semis(string)
      semis = [string]
      if string.length > 1
        0.upto(string.length-1) do |i|
          semis << string[0,i] + string[i+1,string.length]
        end
      end
      return semis
    end
    
  end
end
