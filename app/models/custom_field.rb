class CustomField < ApplicationRecord
  # Associations
  belongs_to :user

  # This means: "When I delete a CustomField, also delete all related ClientCustomFieldValue records"
  has_many :client_custom_field_values, dependent: :destroy
  has_many :clients, through: :client_custom_field_values

  # Validations
  validates :field_name, presence: true, uniqueness: { scope: :user_id }, length: { minimum: 2, maximum: 100 }
  validates :field_type, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }
  validates :user, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }

  # Callbacks
  before_validation :set_defaults

  private

  def set_defaults
    self.field_type ||= "measurement"
    self.is_active = true if is_active.nil?
  end
end


# Vague examples
#
# 1. custom_fields table
# | id | field_name | field_type   |
# |----|------------|--------------|
# | 1  | Height     | measurement  |
# | 2  | Weight     | measurement  |
# | 3  | Goal       | text         |
#
# 2. clients table
# | id | name       | email           |
# |----|------------|-----------------|
# | 1  | John Doe   | john@email.com  |
# | 2  | Jane Smith | jane@email.com  |
#
# 3. client_custom_field_values table (Join/Junction table)
# | id | client_id | custom_field_id | value    |
# |----|-----------|-----------------|----------|
# | 1  | 1         | 1               | 180cm    |
# | 2  | 1         | 2               | 75kg     |
# | 3  | 2         | 1               | 165cm    |
# | 4  | 2         | 3               | Lose 5kg |
