require File.dirname(__FILE__) + '/test_helper'

class LiquidTemplateTest < ActiveSupport::TestCase
  def setup
    LiquidTemplate.delete_all
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

  test 'find_by_name returns nil if not even default template exists' do
    assert_nil LiquidTemplate.find_by_name('ninjas!')
  end
end
