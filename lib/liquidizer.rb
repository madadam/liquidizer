require 'liquidizer/controller_extensions'
require 'liquidizer/migration_extensions'
require 'liquidizer/liquid_template'
      
module Liquidizer
  mattr_accessor :template_path

  if defined?(Rails)
    self.template_path = "#{Rails.root}/db/liquid_templates"
  end
end
