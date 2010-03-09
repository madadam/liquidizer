require 'liquidizer/controller_extensions'
require 'liquidizer/migration_extensions'
require 'liquidizer/liquid_template'
      
module Liquidizer
  # The path the default liquid templates are stored.
  mattr_accessor :template_paths
  self.template_paths = []

  # Module for drops. When instance variable is passed to a template, it's wrapped with a drop.
  # This is a module the drops are looked up. If nil, the drops are looked up in the global
  # namespace.
  mattr_accessor :drop_module

  if defined?(Rails)
    self.template_paths << "#{Rails.root}/db/liquid_templates"
  end
end
