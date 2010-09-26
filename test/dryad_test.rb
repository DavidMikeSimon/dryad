require 'test_helper'

class DryadTest < Test::Unit::TestCase
  def test_simple_tag
    assert_dryad_output "<foo>Bar</foo>" do
      tag! :foo do
        "Bar"
      end
    end
  end

  def test_empty_tag
    assert_dryad_output "<foo/>" do
      tag! :foo
    end
    
    assert_dryad_output "<foo/>" do
      tag! :foo do
      end
    end
  end

  def test_empty_tag_due_to_whitespace_stripping
    assert_dryad_output "<foo/>" do
      tag! :foo do
        "    "
      end
    end
  end

  def test_whitespace_stripping
    assert_dryad_output "<foo>bar</foo>" do
      tag! :foo do
        "   bar   "
      end
    end
  end
end
