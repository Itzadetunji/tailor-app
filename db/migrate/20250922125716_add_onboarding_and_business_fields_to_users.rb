class AddOnboardingAndBusinessFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :has_onboarded, :boolean, default: false, null: false
    add_column :users, :profession, :string, null: true
    add_column :users, :business_name, :string, null: true
    add_column :users, :business_address, :text, null: true

    # Add index on has_onboarded for efficient queries
    add_index :users, :has_onboarded

    # Add index on profession for filtering/searching
    add_index :users, :profession
  end
end
