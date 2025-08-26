class CreateTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :tokens, :token, unique: true
  end
end
