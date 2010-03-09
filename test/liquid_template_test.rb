require File.dirname(__FILE__) + '/test_helper'

class LiquidTemplateTest < ActiveSupport::TestCase
  def setup
    LiquidTemplate.delete_all
    @old_template_paths = Liquidizer.template_paths
  end

  def teardown
    Liquidizer.template_paths = @old_template_paths
  end

  test 'find_by_name finds template by name if it exists' do
    one = LiquidTemplate.create!(:name => 'posts/index')
    two = LiquidTemplate.create!(:name => 'posts/show')

    assert_equal one, LiquidTemplate.find_by_name('posts/index')
  end

  test 'find_by_name fallbacks to default template' do
    expected_content = File.read(File.dirname(__FILE__) + '/fixtures/posts/index.liquid')
    found = LiquidTemplate.find_by_name('posts/index')

    assert_equal expected_content, found.content
  end

  test 'find_by_name searches template in all template paths' do
    Liquidizer.template_paths = [File.dirname(__FILE__) + '/fixtures/path_one',
                                 File.dirname(__FILE__) + '/fixtures/path_two']

    expected_one = File.read(File.dirname(__FILE__) + '/fixtures/path_one/template_one.liquid')
    expected_two = File.read(File.dirname(__FILE__) + '/fixtures/path_two/template_two.liquid')

    assert_equal expected_one, LiquidTemplate.find_by_name('template_one').content
    assert_equal expected_two, LiquidTemplate.find_by_name('template_two').content
  end

  test 'find_by_name returns nil if not even default template exists' do
    assert_nil LiquidTemplate.find_by_name('ninjas!')
  end
end
