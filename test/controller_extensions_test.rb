require File.dirname(__FILE__) + '/test_helper'

class BaseController < ActionController::Base
  append_view_path File.dirname(__FILE__) + '/fixtures'

  private

  def liquid_templates
    Blog.first.liquid_templates
  end
end

class PostsController < BaseController
  liquify

  def index
    @title = 'Hello blog!' 
  end

  def update
    render :action => 'edit'
  end
end

class CommentsController < BaseController
  liquify :show
  liquify :edit, :as => 'funky_comments_edit'

  def index
  end

  def show
  end

  def edit
  end
end

class RatingsController < BaseController
  liquify :show
  liquify_layout

  def show
  end

  def edit
  end
end

# class SpamController < BaseController
#   layout 'spam'
#   liquify :all
# 
#   def index
#   end
# end

class ControllerExtensionsTest < ActionController::TestCase
  self.controller_class = nil

  def setup
    Blog.destroy_all
    @blog = Blog.create!(:title => 'Awesome blog about ninjas and stuff')
  end
  
  test 'renders with liquid template' do
    setup_controller(PostsController)

    get :index
    assert_select 'p', 'This is posts template.'
  end

  test 'passes instance variables to liquid template' do
    setup_controller(PostsController)

    get :index
    assert_select 'h1', /Hello blog!/
  end

  test 'renders with liquid template when explicit action specified' do
    setup_controller(PostsController)

    @blog.liquid_templates.create!(:name => 'posts/edit',   :content => "<p>edit post</p>")
    @blog.liquid_templates.create!(:name => 'posts/update', :content => "<p>update post</p>")

    get :update
    assert_select 'p', 'edit post'
  end

  test 'does not render with liquid template actions that were not liquified' do
    setup_controller(CommentsController)

    get :index
    assert_select 'h1', 'This is not liquid template'
  end

  test 'renders with liquid template with custom name' do
    setup_controller(CommentsController)

    @blog.liquid_templates.create!(:name    => 'comments/edit',
                                   :content => "<p>default edit</p>")

    @blog.liquid_templates.create!(:name    => 'funky_comments_edit',
                                   :content => "<p>funky edit</p>")

    get :edit
    assert_select 'p', 'funky edit'
  end

  test 'renders liquid template with liquid layout' do
    setup_controller(RatingsController)

    @blog.liquid_templates.create!(
      :name => 'ratings/show', :content => '<p>This is liquid template</p>')

    @blog.liquid_templates.create!(
      :name => 'layout', :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :show
    assert_select '#layout p', 'This is liquid template'
  end
  
  test 'renders solid template with liquid layout' do
    setup_controller(RatingsController)

    @blog.liquid_templates.create!(
      :name => 'layout', :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :edit
    assert_select '#layout p', 'This is not liquid template'
  end


  private

  def setup_controller(controller_class)
    self.class.prepare_controller_class(controller_class)
  
    # This is copied over from ActionController::TestCase.setup_controller_request_and_response
    @controller = controller_class.new
    @controller.request = @request
    @controller.params = {}
    @controller.send(:initialize_current_url)
  end
end
