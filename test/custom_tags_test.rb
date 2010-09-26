require 'test_helper'

class CustomTagsTest < Test::Unit::TestCase
  def test_simple_tag_def
    @taglib.define_tag "foo" do
      raw_tag! :bar
    end

    assert_dryad_output "<bar/>" do
      foo
    end
  end

  def test_block_passthru
    @taglib.define_tag "foo" do
      raw_tag! :bar, &content_arg!
    end
 
    assert_dryad_output "<bar>narf</bar>" do
      foo do
        raw_text! "narf"
      end
    end
  end
end
