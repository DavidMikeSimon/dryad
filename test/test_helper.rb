require 'ftools'
$: << File.join(File.dirname($0), "..", "lib")

require 'dryad'
require 'html_format'
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

  def assert_dryad_raise(exception, taglib, &block)
    assert_raise exception do
      taglib.output(StringIO.new, &block)
    end
  end
end
