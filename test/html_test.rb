require 'test_helper'
require 'html_tags'

class HtmlTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
    @taglib.add_module(HtmlTags)

    @simple_document_block = proc do
      html do
        body do
          p do
            v("Hello "); b{v("world!")}
          end
          hr
          p do
            v("I am a banana!")
          end
        end
      end
    end
  end

  def test_simple_document
    doc = "<html><body><p>Hello <b>world!</b></p><hr/><p>I am a banana!</p></body></html>"
    assert_output doc, @taglib, &@simple_document_block
  end

  def test_default_setting
    doc = '<html><body><p>Hello <b class="foo">world!</b></p><hr/><p>I am a banana!</p></body></html>'
    sdb = @simple_document_block
    assert_output doc, @taglib do
      def b(params = {}, &block)
        params["class"] = "foo"
        super
      end
      
      instance_eval &sdb
    end
  end
end
