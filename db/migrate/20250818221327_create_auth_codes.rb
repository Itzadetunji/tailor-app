class CreateAuthCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :auth_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code
      t.string :token
      t.datetime :expires_at
      t.datetime :used_at

      t.timestamps
    end
    add_index :auth_codes, :code, unique: true
    add_index :auth_codes, :token, unique: true
  end
end
