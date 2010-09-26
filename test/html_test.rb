require 'test_helper'
require 'html_tags'

class HtmlTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
    @taglib.add_module(HtmlTags)
  end

  def test_simple_document
    doc = "<html><body><p>Hello <b>world!</b></p><hr/><p>I am a banana!</p></body></html>"
    assert_output doc, @taglib do
      html do
        body do
          p do
            raw_text! "Hello "
            b do
              raw_text! "world!"
            end
          end
          hr
          p do
            raw_text! "I am a banana!"
          end
        end
      end
    end
  end
end
