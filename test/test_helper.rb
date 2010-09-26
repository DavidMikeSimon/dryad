require 'dryad'
require 'rubygems'

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def setup
    @dryad = Dryad.new
  end
  
  def assert_dryad_output(output, &block)
    result = @dryad.build_document(&block)
    assert_equal output, result
  end
end
