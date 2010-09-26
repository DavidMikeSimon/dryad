require 'dryad'
require 'rubygems'

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def assert_output(expected_output, taglib, &block)
    assert_equal expected_output, taglib.output(&block)
  end
end
