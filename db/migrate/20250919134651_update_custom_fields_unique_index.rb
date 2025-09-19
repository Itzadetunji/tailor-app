class UpdateCustomFieldsUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove the old unique index on field_name
    remove_index :custom_fields, :field_name

    # Add a new composite unique index on field_name and user_id
    add_index :custom_fields, [ :field_name, :user_id ], unique: true
  end
end
