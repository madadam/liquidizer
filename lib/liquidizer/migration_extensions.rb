module Liquidizer
  module MigrationExtensions
    def create_liquid_templates_table
      create_table :liquid_templates do |table|
        table.belongs_to :storage, :polymorphic => true
        table.string :name
        table.text :content
      end

      add_index :liquid_templates, :name
      add_index :liquid_templates, [:storage_id, :storage_type]
    end

    def drop_liquid_templates_table
      drop_table :liquid_templates
    end
  end
end

if defined?(ActiveRecord::Migration)
  ActiveRecord::Migration.extend(Liquidizer::MigrationExtensions)
end
