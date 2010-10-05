require 'test/test_helper'
require 'html_tags'

class HtmlTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
    @taglib.add_module Dryad::HtmlTags

    @simple_document_block = proc do
      html do
        body do
          p{ v"Hello "; b"world!" }
          hr
          p"I am a banana!"
        end
      end
    end
  end

  def test_simple_document
    doc = "<html><body><p>Hello <b>world!</b></p><hr/><p>I am a banana!</p></body></html>"
    assert_output doc, @taglib, &@simple_document_block
  end
end
