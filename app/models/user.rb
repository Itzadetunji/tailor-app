class User < ApplicationRecord
  has_many :auth_codes, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  # first_name and last_name are optional now so users can sign up with email only
  
  before_save :downcase_email
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def generate_auth_code!
    # Ensure no more than one active magic link: delete any existing unused codes,
    # then create a fresh one inside a transaction.
    ApplicationRecord.transaction do
      auth_codes.where(used_at: nil).delete_all

      # Generate new 6-digit code
      code = SecureRandom.random_number(100000..999999).to_s
      token = SecureRandom.urlsafe_base64(32)

      auth_codes.create!(
        code: code,
        token: token,
        expires_at: 15.minutes.from_now
      )
    end
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
