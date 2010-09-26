require 'test_helper'

class SimpleTagsTest < Test::Unit::TestCase
  def test_very_simple_tag!
    assert_dryad_output "<foo>Bar</foo>" do
      tag! :foo do
        raw_text! "Bar"
      end
    end
  end

  def test_empty_tag!
    assert_dryad_output "<foo/>" do
      tag! :foo
    end
    
    assert_dryad_output "<foo/>" do
      tag! :foo do
      end
    end
  end

  def test_empty_tag!_due_to_whitespace_stripping
    assert_dryad_output "<foo/>" do
      tag! :foo do
        raw_text! "    "
      end
    end
  end

  def test_whitespace_stripping
    assert_dryad_output "<foo>bar</foo>" do
      tag! :foo do
        raw_text! "   bar   "
      end
    end
  end

  def test_simple_concatenation
    assert_dryad_output "<foo>xyzzy</foo>" do
      tag! :foo do
        raw_text! "xy"
        raw_text! "zzy"
      end
    end
  end

  def test_nested_tags
    assert_dryad_output "<foo><narf>bork</narf></foo>" do
      tag! :foo do
        tag! :narf do
          raw_text! "bork"
        end
      end
    end
  end

  def test_attributes
    assert_dryad_output '<foo x="y">bork</foo>' do
      tag! :foo, :x => "y" do
        raw_text! "bork"
      end
    end

    assert_dryad_output '<foo x="y"/>' do
      tag! :foo, :x => "y"
    end
  end
end
