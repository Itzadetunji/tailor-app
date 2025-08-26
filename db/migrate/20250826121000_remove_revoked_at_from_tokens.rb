class RemoveRevokedAtFromTokens < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:tokens, :revoked_at)
      remove_column :tokens, :revoked_at, :datetime
    end
  end
end
