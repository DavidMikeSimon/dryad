require 'test_helper'

class DryadTest < Test::Unit::TestCase
  def test_single_tag
    assert_dryad_output "<foo>Bar</foo>" do
      tag!(:foo) do
        "Bar"
      end
    end
  end
end
