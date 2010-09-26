require 'dryad'
require 'rubygems'

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
  end
  
  def assert_dryad_output(output, &block)
    result = @taglib.build_document(&block)
    assert_equal output, result
  end
end
