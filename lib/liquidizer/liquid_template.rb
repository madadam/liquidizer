module Liquidizer
  module LiquidTemplate
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_by_name(name)
        first(:conditions => {:name => name}) || find_default_by_name(name)
      end

      def find_default_by_name(name)
        file_name = File.join(Liquidizer.template_path, name) + '.liquid'

        if File.exist?(file_name)
          new(:name => name, :content => File.read(file_name))
        else
          nil
        end
      end
    end
  end
end
