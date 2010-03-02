require File.dirname(__FILE__) + '/test_helper'

class TemplateTest < ActiveSupport::TestCase
  def setup
    Liquidizer::Template.delete_all
  end

  test 'find_by_name finds template by name if it exists' do
    one = Liquidizer::Template.create!(:name => 'posts/index')
    two = Liquidizer::Template.create!(:name => 'posts/show')

    assert_equal one, Liquidizer::Template.find_by_name('posts/index')
  end

  test 'find_by_name fallbacks to default template' do
    expected_content = File.read(File.dirname(__FILE__) + '/fixtures/posts/index.liquid')
    found = Liquidizer::Template.find_by_name('posts/index')

    assert_equal expected_content, found.content
  end

  test 'find_by_name returns nil if not even default template exists' do
    assert_nil Liquidizer::Template.find_by_name('ninjas!')
  end
end
