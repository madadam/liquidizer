module Liquidizer
  module LiquidTemplate
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_by_name(name)
        first(:conditions => {:name => name}) || load_default(name)
      end

      def load_default(name)
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
