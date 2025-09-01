class AddUserToClients < ActiveRecord::Migration[8.0]
  def change
    # Add the user_id column as nullable first (bigint to match users table)
    add_reference :clients, :user, null: true, foreign_key: true
    
    # Create a default user if one doesn't exist
    reversible do |dir|
      dir.up do
        if User.count == 0
          User.create!(
            email: 'admin@example.com',
            first_name: 'Admin',
            last_name: 'User'
          )
        end
        
        # Assign existing clients to the first user
        default_user = User.first
        Client.where(user_id: nil).update_all(user_id: default_user.id) if default_user
      end
    end
    
    # Now make the column non-nullable
    change_column_null :clients, :user_id, false
  end
end
