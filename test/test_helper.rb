require 'dryad'
require 'rubygems'

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def setup
    puts "SETUP"
  end
end
