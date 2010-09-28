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

  def test_attributes_passthru
    @taglib.add do
      def foo(attributes)
        raw_tag! :bar, attributes
      end
    end

    assert_output '<bar x="y"/>', @taglib do
      foo :x => "y"
    end
  end

  def test_temporary_redefinition
    @taglib.add do
      def foo
        raw_tag! :bar
      end
    end

    assert_output '<bar/><narf/><bar/>', @taglib do
      run! do
        foo
        def foo
          raw_tag! :narf
        end
        foo
      end

      foo
    end
  end

  def test_class_concatenation
    @taglib.add do
      def bar(subject, args = {})
        raw_tag! :bar, args + {:class => "a"} do
          v subject
        end
      end
      
      def foo(args = {})
        bar "narf", args + {:class => "b"}
      end
    end

    assert_output '<bar class="c b a">narf</bar>', @taglib do
      foo(:class => "c")
    end
  end
end
