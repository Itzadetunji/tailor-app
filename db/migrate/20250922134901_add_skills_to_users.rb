class AddSkillsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :skills, :string, array: true, default: [], null: true

    # Add index for efficient querying of array elements
    add_index :users, :skills, using: 'gin'
  end
end
