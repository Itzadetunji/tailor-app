class ConvertUserIdToUuid < ActiveRecord::Migration[8.0]
  def up
    # Ensure uuid-ossp extension is enabled
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    # Add temporary UUID column to users table
    add_column :users, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    # Populate UUID for existing users
    User.reset_column_information
    User.find_each do |user|
      user.update_column(:uuid, SecureRandom.uuid) if user.uuid.blank?
    end

    # Add temporary UUID columns to related tables
    add_column :auth_codes, :user_uuid, :uuid
    add_column :clients, :user_uuid, :uuid
    add_column :custom_fields, :user_uuid, :uuid
    add_column :tokens, :user_uuid, :uuid

    # Populate the UUID foreign keys
    execute <<-SQL
      UPDATE auth_codes#{' '}
      SET user_uuid = users.uuid#{' '}
      FROM users#{' '}
      WHERE auth_codes.user_id = users.id;
    SQL

    execute <<-SQL
      UPDATE clients#{' '}
      SET user_uuid = users.uuid#{' '}
      FROM users#{' '}
      WHERE clients.user_id = users.id;
    SQL

    execute <<-SQL
      UPDATE custom_fields#{' '}
      SET user_uuid = users.uuid#{' '}
      FROM users#{' '}
      WHERE custom_fields.user_id = users.id;
    SQL

    execute <<-SQL
      UPDATE tokens#{' '}
      SET user_uuid = users.uuid#{' '}
      FROM users#{' '}
      WHERE tokens.user_id = users.id;
    SQL

    # Remove old foreign key constraints
    remove_foreign_key :auth_codes, :users
    remove_foreign_key :clients, :users
    remove_foreign_key :custom_fields, :users
    remove_foreign_key :tokens, :users

    # Remove old columns
    remove_column :auth_codes, :user_id
    remove_column :clients, :user_id
    remove_column :custom_fields, :user_id
    remove_column :tokens, :user_id

    # Remove old primary key and rename uuid column to id
    remove_column :users, :id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"

    # Rename UUID foreign key columns and add constraints
    rename_column :auth_codes, :user_uuid, :user_id
    rename_column :clients, :user_uuid, :user_id
    rename_column :custom_fields, :user_uuid, :user_id
    rename_column :tokens, :user_uuid, :user_id

    # Make foreign key columns not null
    change_column_null :auth_codes, :user_id, false
    change_column_null :clients, :user_id, true  # Keep nullable as per original migration
    change_column_null :custom_fields, :user_id, true  # Keep nullable as per original migration
    change_column_null :tokens, :user_id, false

    # Add foreign key constraints
    add_foreign_key :auth_codes, :users, column: :user_id, primary_key: :id
    add_foreign_key :clients, :users, column: :user_id, primary_key: :id
    add_foreign_key :custom_fields, :users, column: :user_id, primary_key: :id
    add_foreign_key :tokens, :users, column: :user_id, primary_key: :id

    # Add indexes
    add_index :auth_codes, :user_id
    add_index :clients, :user_id
    add_index :custom_fields, :user_id
    add_index :tokens, :user_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot reverse UUID conversion migration safely"
  end
end
