class CreateCustomFields < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_fields, id: :uuid do |t|
      t.string :field_name, null: false
      t.string :field_type, default: 'measurement'
      t.boolean :is_active, default: true

      t.timestamps
    end
    
    add_index :custom_fields, :field_name, unique: true
    add_index :custom_fields, :is_active
  end
end
