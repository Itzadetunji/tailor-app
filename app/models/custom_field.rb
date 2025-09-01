class CustomField < ApplicationRecord
  # Associations
  has_many :client_custom_field_values, dependent: :destroy
  has_many :clients, through: :client_custom_field_values
  
  # Validations
  validates :field_name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :field_type, presence: true
  validates :is_active, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  
  # Callbacks
  before_validation :set_defaults
  
  private
  
  def set_defaults
    self.field_type ||= 'measurement'
    self.is_active = true if is_active.nil?
  end
end
