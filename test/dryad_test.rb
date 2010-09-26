require 'test_helper'

class DryadTest < Test::Unit::TestCase
  def test_simple_tag!
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
end
