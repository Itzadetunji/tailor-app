class RemoveEmailUniquenessAndPhoneUniquenessFromClients < ActiveRecord::Migration[8.0]
  def up
    # Remove uniqueness constraint from email if it exists as an index
    remove_index :clients, :email if index_exists?(:clients, :email)
    remove_index :clients, :phone_number if index_exists?(:clients, :phone_number)
  end

  def down
    # Add uniqueness constraint back to email
    add_index :clients, :email, unique: true unless index_exists?(:clients, :email)
    add_index :clients, :phone_number, unique: true unless index_exists?(:clients, :phone_number)
  end
end
