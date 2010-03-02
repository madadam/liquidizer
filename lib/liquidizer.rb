require 'liquidizer/controller_extensions'
require 'liquidizer/model_extensions'
require 'liquidizer/migration_extensions'

module Liquidizer
  mattr_accessor :template_directory

  if defined?(Rails)
    self.template_directory = "#{Rails.root}/db/liquid_templates"
  else
    self.template_directory = ''
  end
end
