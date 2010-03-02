require 'liquidizer/template'

module Liquidizer
  module ModelExtensions
    def has_liquid_templates(options = {})
      has_many :liquid_templates, :class_name => 'Liquidizer::Template',
                                  :as         => :storage,
                                  :dependent  => :destroy
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend(Liquidizer::ModelExtensions)
end
