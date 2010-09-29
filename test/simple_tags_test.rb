require 'test/test_helper'
require 'cgi'

class SimpleTagsTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
  end

  def test_very_simple_raw_tag
    assert_output "<foo>Bar</foo>", @taglib do
      raw_tag! :foo do
        raw_text! "Bar"
      end
    end
  end

  def test_empty_raw_tag
    assert_output "<foo/>", @taglib do
      raw_tag! :foo
    end
  end

  def test_simple_concatenation
    assert_output "<foo>xyzzy</foo>", @taglib do
      raw_tag! :foo do
        raw_text! "xy"
        raw_text! "zzy"
      end
    end
  end

  def test_nested_tags
    assert_output "<foo><narf>bork</narf></foo>", @taglib do
      raw_tag! :foo do
        raw_tag! :narf do
          raw_text! "bork"
        end
      end
    end
  end

  def test_attributes
    assert_output '<foo x="y">bork</foo>', @taglib do
      raw_tag! :foo, :x => "y" do
        raw_text! "bork"
      end
    end

    assert_output '<foo x="y"/>', @taglib do
      raw_tag! :foo, :x => "y"
    end
  end

  def test_io_output
    sio = StringIO.new
    @taglib.output sio do
      raw_tag! :foo
    end
    @taglib.output sio do
      raw_tag! :bar
    end
    assert_equal "<foo/><bar/>", sio.string
  end

  def test_text_escaping
    assert_output 'One &lt; two', @taglib do
      text! "One < two"
    end
  end

  def test_attribute_escaping
    assert_output '<foo bar="Joe said &quot;hi&quot;"/>', @taglib do
      raw_tag! :foo, :bar => 'Joe said "hi"'
    end
  end
end
