require 'test/unit'
require 'action_controller'
require 'active_record'
require 'active_support/test_case'

$: << File.dirname(__FILE__) + '/../lib'
$: << File.dirname(__FILE__) + '/../app/models'

require 'liquidizer'
require 'liquid_template'

Liquidizer.template_paths = [File.dirname(__FILE__) + '/fixtures']

# Establish a temporary sqlite3 db for testing.
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Base.logger # instantiate logger
ActiveRecord::Schema.define(:version => 1) do
  create_liquid_templates_table
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end
