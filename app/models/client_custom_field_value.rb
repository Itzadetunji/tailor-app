class ClientCustomFieldValue < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :custom_field
  
  # Validations
  validates :client_id, uniqueness: { scope: :custom_field_id }
  validates :value, presence: true
  validate :custom_field_must_be_active
  
  private
  
  def custom_field_must_be_active
    return unless custom_field
    
    errors.add(:custom_field, 'must be active') unless custom_field.is_active?
  end
end
