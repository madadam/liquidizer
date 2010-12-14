require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'liquidizer/file_system'

class FileSystemTest < ActiveSupport::TestCase
  def setup
    LiquidTemplate.destroy_all
  end

  test 'reads templates from the database' do
    LiquidTemplate.create!(:name => 'posts/index', :content => 'These are posts')
    LiquidTemplate.create!(:name => 'comments/show', :content => 'This is a comment')

    file_system = Liquidizer::FileSystem.new { LiquidTemplate }

    assert_equal 'These are posts', file_system.read_template_file('posts/index')
    assert_equal 'This is a comment', file_system.read_template_file('comments/show')
  end
end
