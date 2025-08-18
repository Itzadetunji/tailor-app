class User < ApplicationRecord
  has_many :auth_codes, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  before_save :downcase_email
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def generate_auth_code!
    # Expire any existing unused codes
    auth_codes.where(used_at: nil).update_all(used_at: Time.current)
    
    # Generate new 6-digit code
    code = SecureRandom.random_number(100000..999999).to_s
    token = SecureRandom.urlsafe_base64(32)
    
    auth_codes.create!(
      code: code,
      token: token,
      expires_at: 30.minutes.from_now
    )
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
