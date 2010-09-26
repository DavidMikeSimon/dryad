require 'test_helper'
require 'stringio'

class CustomTagsTest < Test::Unit::TestCase
  def setup
    @taglib = Dryad::TagLibrary.new
  end

  def test_simple_tag_def
    @taglib.add do
      def foo
        raw_tag! :bar
      end
    end

    assert_output "<bar/>", @taglib do
      foo
    end
  end

  def test_invalid_tag
    assert_raise Dryad::NoSuchTagError do
      sio = StringIO.new
      @taglib.output sio do
        foobar
      end
    end
  end

  def test_block_passthru
    @taglib.add do
      def foo(&block)
        raw_tag! :bar, &block
      end
    end
     
    assert_output "<bar>narf</bar>", @taglib do
      foo do
        raw_text! "narf"
      end
    end
  end

  def test_redef_for_prepend_and_append
    @taglib.add do
      def foo(&block)
        raw_tag! :bar, &block
      end
    end

    assert_output "XYZZY<bar>narf</bar>KABLOOIE", @taglib do
      def foo(&block)
        raw_text! "XYZZY"
        super
        raw_text! "KABLOOIE"
      end

      foo do
        raw_text! "narf"
      end
    end
  end

  def test_redef_for_insertion
    @taglib.add do
      def foo(&block)
        raw_tag! :bar, &block
      end
    end

    assert_output "<bar>BEFOREnarfAFTER</bar>", @taglib do
      def foo(&block)
        super do
          raw_text! "BEFORE"
          block.call
          raw_text! "AFTER"
        end
      end

      foo do
        raw_text! "narf"
      end
    end
  end
end
