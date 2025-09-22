class ClientCustomFieldValue < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :custom_field

  # Validations
  validates :client_id, uniqueness: { scope: :custom_field_id }
  validates :value, presence: true
  validate :custom_field_must_be_active
  validate :custom_field_must_belong_to_same_user

  private

  def custom_field_must_be_active
    return unless custom_field

    errors.add(:custom_field, "must be active") unless custom_field.is_active?
  end

  def custom_field_must_belong_to_same_user
    return unless custom_field && client

    unless custom_field.user_id == client.user_id
      errors.add(:custom_field, "must belong to the same user as the client")
    end
  end
end
