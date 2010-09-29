require 'ftools'
$: << File.join(File.dirname($0), "..", "lib")

require 'dryad'
require 'rubygems'
require 'stringio'

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def assert_output(expected_output, taglib, &block)
    sio = StringIO.new
    taglib.output(sio, &block)
    assert_equal expected_output, sio.string
  end
end
