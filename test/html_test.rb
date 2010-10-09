require 'test/test_helper'
require 'html_tags'

class HtmlTest < Test::Unit::TestCase
  def setup
    @dryad = Dryad::Dryad.new
    @dryad.add_module Dryad::HtmlFormat
    @dryad.add_module Dryad::HtmlTags

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
    assert_output doc, @dryad, &@simple_document_block
  end
end
