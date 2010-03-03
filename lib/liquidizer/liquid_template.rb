module Liquidizer
  module LiquidTemplate
    def self.included(base)
      base.extend(ClassMethods)
      base.class_inheritable_accessor :template_directory

      if defined?(Rails)
        base.template_directory = "#{Rails.root}/db/liquid_templates"
      else
        base.template_directory = ''
      end
    end

    module ClassMethods
      def find_by_name(name)
        first(:conditions => {:name => name}) || load_default(name)
      end

      def load_default(name)
        file_name = File.join(template_directory, name) + '.liquid'

        if File.exist?(file_name)
          new(:name => name, :content => File.read(file_name))
        else
          nil
        end
      end
    end
  end
end
