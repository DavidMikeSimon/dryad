require 'test_helper'

class CustomTagsTest < Test::Unit::TestCase
  def test_tag_def_as_rename
    @dryad.define_tag "foo" do
      tag! :bar
    end

    assert_dryad_output "<bar/>" do
      foo
    end
  end
end
