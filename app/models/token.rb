class Token < ApplicationRecord
  belongs_to :user
  # A token is active if it hasn't expired. We delete token records to revoke them.
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  # No revoke method — tokens are removed from DB when revoked.
end
