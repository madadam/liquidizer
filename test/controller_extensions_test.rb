require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class BaseController < ActionController::Base
  append_view_path File.dirname(__FILE__) + '/fixtures'

  private

  def current_liquid_templates
    LiquidTemplate
  end
end

class RailsController < BaseController

  def show
    render :edit, :layout => false
  end

  def edit
    render 'posts/show'
  end

  def update
    render
  end

end

class PostsController < BaseController
  layout 'layout'
  liquify

  def index
    @title = 'Hello blog!'
    @posts = [Post.new(:title => 'First post'), Post.new(:title => 'Second post')]
  end

  def show
    @post = Post.new(:title => 'Liquidizer is awesome!')
  end

  def update
    render :action => 'edit'
  end

  def create
    render :status => :created
  end

  def new
    render :template => 'more_awesome_new'
  end

  def edit
    render :layout => 'awesome_layout'
  end

  def destroy
    render :nothing => true
  end
end

class CommentsController < BaseController
  layout 'layout'
  liquify :only => :show

  def index
  end

  def show
  end

  def new
    render :partial => 'stuff'
  end

  def create
    render :text => 'create'
  end
end

class RatingsController < BaseController
  liquify :layout => false

  def show
  end
end

class SpamsController < BaseController
  layout 'layout'

  def index
  end
end

class Post
  def initialize(attributes = {})
    self.title = attributes[:title]
  end

  attr_accessor :title
end

class PostDrop < Liquid::Drop
  def initialize(post)
    @post = post
  end

  def title
    "<em>#{@post.title}</em>"
  end
end

module CoolDrops
  class PostDrop < Liquid::Drop
    def initialize(post)
      @post = post
    end

    def title
      "<strong>#{@post.title}</strong>"
    end
  end
end

class ControllerExtensionsTest < ActionController::TestCase
  self.controller_class = nil

  def setup
    LiquidTemplate.destroy_all
  end

  def teardown
    Liquidizer.drop_module = nil
  end

  test 'renders with liquid template' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/index', :content => "<p>This is liquid template</p>")

    get :index
    assert_select 'p', 'This is liquid template'
  end

  test 'passes instance variables to liquid template' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/index', :content => "<h1>{{ title }}</h1>")

    get :index
    assert_select 'h1', /Hello blog!/
  end

  test 'renders with liquid template when explicit action specified' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/edit', :content => "<p>edit post</p>")
    LiquidTemplate.create!(:name => 'posts/update', :content => "<p>update post</p>")

    get :update
    assert_select 'p', 'edit post'
  end

  test 'renders with liquid template when explicit template specified' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'more_awesome_new', :content => "<p>more awesome new</p>")
    LiquidTemplate.create!(:name => 'posts/new', :content => "<p>less awesome new</p>")

    get :new
    assert_select 'p', 'more awesome new'
  end

  test 'preserves additional render options' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/create', :content => "<p>create post</p>")

    get :create
    assert_response :created
  end

  test 'does not render with liquid template actions that were not liquified' do
    setup_controller(CommentsController)

    get :index
    assert_select 'h1', 'This is not liquid template'
  end

  test 'does not render with liquid if liquify macro not called at all' do
    setup_controller(SpamsController)

    get :index
    assert_select '#layout h1', 'This is not liquid template'
  end

  test 'renders liquid template with liquid layout' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/show', :content => '<p>This is liquid template</p>')
    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :show
    assert_select '#layout p', 'This is liquid template'
  end

  test 'renders solid template with liquid layout' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :show
    assert_select '#layout p', 'This is not liquid template'
  end

  test 'renders with overriden liquid layout' do
    setup_controller(PostsController)

    LiquidTemplate.create!(
      :name => 'awesome_layout',
      :content => '<div id="awesome_layout">{{ content_for_layout }}</div>')

    LiquidTemplate.create!(
      :name => 'layout',
      :content => '<div id="layout">{{ content_for_layout }}</div>')

    LiquidTemplate.create!(
      :name => 'posts/edit',
      :content => '<p>Awesome liquid template</p>')

    get :edit
    assert_select '#awesome_layout p'
  end

  test 'does not render liquid layout if disabled' do
    setup_controller(RatingsController)

    LiquidTemplate.create!(:name => 'ratings/show', :content => '<p>This is liquid template</p>')
    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :show
    assert_select 'p', 'This is liquid template'
    assert_select '#layout', false
  end

  test 'does not apply liquid layout to render :partial' do
    setup_controller(CommentsController)

    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :new
    assert_select '#layout', false
  end

  test 'does not apply liquid layout to render :text' do
    setup_controller(CommentsController)

    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :create
    assert_select '#layout', false
  end

  test 'applies liquid layout to render :template' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'more_awesome_new', :content => "<p>more awesome new</p>")
    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :new
    assert_select '#layout p', 'more awesome new'
  end

  test 'does not apply liquid layout to render :nothing => true' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'layout',
                           :content => '<div id="layout">{{ content_for_layout }}</div>')

    get :destroy
    assert @response.body.blank?, "response should be blank, but was #{@response.body.inspect}"
  end

  test 'dropifies instance variables' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/show', :content => '<h1>{{ post.title }}</h1>')

    get :show
    assert_select 'h1 em', 'Liquidizer is awesome!'
  end

  test 'dropifies instance variables using namespaced drop' do
    setup_controller(PostsController)
    Liquidizer.drop_module = CoolDrops

    LiquidTemplate.create!(:name => 'posts/show', :content => '<h1>{{ post.title }}</h1>')

    get :show
    assert_select 'h1 strong', 'Liquidizer is awesome!'
  end

  test 'dropifies array elements' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/index',
                           :content => '{% for post in posts %} {{ post.title }} {% endfor %}')

    get :index
    assert_select 'em', 'First post'
    assert_select 'em', 'Second post'
  end

  test 'renders partials' do
    setup_controller(PostsController)

    LiquidTemplate.create!(:name => 'posts/show',
                           :content => '<p>This is a template</p> {% include "cool_partial" %}')
    LiquidTemplate.create!(:name => 'cool_partial',
                           :content => '<p>This is a partial</p>')

    get :show
    assert_select 'p', 'This is a template'
    assert_select 'p', 'This is a partial'
  end

  test 'call to render with symbol' do
    setup_controller(RailsController)

    get :show
    assert_select 'p', 'Rails edit action'
    assert_select '#layout', false
  end

  test 'call to render with template name' do
    setup_controller(RailsController)

    get :edit
    assert_select 'p', 'This is not liquid template'
  end

  test 'call to render without anything' do
    setup_controller(RailsController)

    get :update
    assert_select 'p', 'Rails update action'
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
