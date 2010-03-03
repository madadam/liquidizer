module Liquidizer
  module MigrationExtensions
    def create_liquid_templates_table
      create_table :liquid_templates do |table|
        table.string :name
        table.text :content
      end

      add_index :liquid_templates, :name
    end
  end
end

if defined?(ActiveRecord::Migration)
  ActiveRecord::Migration.extend(Liquidizer::MigrationExtensions)
end
