require 'test_helper'

class CustomTagsTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
  end

  def test_simple_tag_def
    @taglib.define_tag "foo" do
      raw_tag! :bar
    end

    assert_output "<bar/>", @taglib do
      foo
    end
  end

  def test_block_passthru
    @taglib.define_tag "foo" do
      raw_tag! :bar, &content_block!
    end
 
    assert_output "<bar>narf</bar>", @taglib do
      foo do
        raw_text! "narf"
      end
    end
  end
end
