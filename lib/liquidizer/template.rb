module Liquidizer
  class Template < ActiveRecord::Base
    set_table_name 'liquid_templates'
    belongs_to :storage, :polymorphic => true

    def self.find_by_name(name)
      first(:conditions => {:name => name}) || load_default(name)
    end

    def self.load_default(name)
      file_name = File.join(Liquidizer.template_directory, name) + '.liquid'

      if File.exist?(file_name)
        new(:name => name, :content => File.read(file_name))
      else
        nil
      end
    end
  end
end
