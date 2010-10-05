require 'test/test_helper'
require 'stringio'

class CustomTagsTest < Test::Unit::TestCase
  def setup
    @dryad = Dryad::Dryad.new
  end

  def test_simple_tag_def
    @dryad.add do
      def foo
        raw_tag :bar
      end
    end

    assert_output "<bar/>", @dryad do
      foo
    end
  end

  def test_block_passthru
    @dryad.add do
      def foo(&block)
        raw_tag :bar, &block
      end
    end
     
    assert_output "<bar>narf</bar>", @dryad do
      foo do
        v"narf"
      end
    end
  end

  def test_attributes_passthru
    @dryad.add do
      def foo
        raw_tag :bar, attributes
      end
    end

    assert_output '<bar x="y"/>', @dryad do
      foo :x => "y"
    end
  end

  def test_temporary_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end
    end

    assert_output '<narf/><bar/>', @dryad do
      run do
        def foo
          raw_tag :narf
        end
        foo
      end

      foo
    end
  end

  def test_nested_temporary_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end

      def xyz
        raw_tag :xyz do
          foo
        end
      end
    end

    assert_output '<xyz><narf/></xyz><xyz><bar/></xyz>', @dryad do
      run do
        def foo
          raw_tag :narf
        end
        xyz
      end

      xyz
    end
  end

  def test_permanent_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end
    end
    
    @dryad.add do
      def foo
        raw_tag :blork
      end
    end

    assert_output '<blork/>', @dryad do
      foo
    end
  end

  def test_block_nested_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end

      def xyz(&block)
        raw_tag :xyz, &block
      end
    end

    @dryad.add do
      def foo
        raw_tag :zarf
      end
    end

    assert_output '<xyz><zarf/></xyz>', @dryad do
      xyz do
        foo
      end
    end
  end

  def test_add_nested_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end

      def xyz
        foo
      end
    end

    @dryad.add do
      def foo
        raw_tag :narf
      end
    end

    assert_output '<narf/>', @dryad do
      xyz
    end
  end
  
  def test_nested_redef
    @dryad.add do
      def foo
        raw_tag :bar
      end

      def xyz
        foo
      end
    end

    assert_output '<narf/>', @dryad do
      def foo
        raw_tag :narf
      end
      xyz
    end
  end

  def test_redef_with_super
    @dryad.add do
      def foo
        raw_tag :bar
      end
    end

    @dryad.add do
      def foo
        raw_tag :zarf do
          super
        end
      end
    end

    assert_output '<zarf><bar/></zarf>', @dryad do
      foo
    end
  end

  def test_class_concatenation
    @dryad.add do
      def bar(subject)
        raw_tag :bar, attributes + {:class => "a"} do
          v subject
        end
      end
      
      def foo
        bar "narf", attributes + {:class => "b"}
      end
    end

    assert_output '<bar class="c b a">narf</bar>', @dryad do
      foo :class => "c"
    end
  end
  
  def test_auto_class_concatenation
    @dryad.add do
      def bar(subject)
        raw_tag :bar, :a!, attributes do
          v subject
        end
      end
      
      def foo
        bar "narf", :b!, attributes
      end
    end

    assert_output '<bar class="c b a">narf</bar>', @dryad do
      foo :c!
    end
  end

  def test_name_error_suggestion
    @dryad.add do
      def duck
      end

      def duke
      end
    end

    exception = nil
    begin
      @dryad.output StringIO.new do
        duk # Whoops, a spelling error
      end
    rescue NameError => e
      exception = e
    end
    assert_kind_of NameError, exception
    assert_equal :duk, exception.name
    assert_match /\nPerhaps you meant one of these methods:\n duck\n duke/, exception.message
    assert_no_match /\bdup\b/, exception.message # Doesn't suggest common Object methods
  end
end
