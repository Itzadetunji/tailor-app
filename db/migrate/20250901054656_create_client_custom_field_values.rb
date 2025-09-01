class CreateClientCustomFieldValues < ActiveRecord::Migration[8.0]
  def change
    create_table :client_custom_field_values, id: :uuid do |t|
      t.references :client, null: false, foreign_key: true, type: :uuid
      t.references :custom_field, null: false, foreign_key: true, type: :uuid
      t.text :value

      t.timestamps
    end
    
    add_index :client_custom_field_values, [:client_id, :custom_field_id], 
              unique: true, name: 'index_client_custom_field_values_unique'
  end
end
