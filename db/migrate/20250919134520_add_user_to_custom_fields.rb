class AddUserToCustomFields < ActiveRecord::Migration[8.0]
  def change
    add_reference :custom_fields, :user, null: true, foreign_key: true, type: :bigint

    # If you want to make it NOT NULL later, you would:
    # 1. First populate existing records with a user_id
    # 2. Then change the column to NOT NULL in a separate migration
    # change_column_null :custom_fields, :user_id, false
  end
end
