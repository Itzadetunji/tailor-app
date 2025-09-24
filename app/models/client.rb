class Client < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :client_custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :client_custom_field_values

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :gender, presence: true, inclusion: { in: %w[Male Female] }
  validates :measurement_unit, presence: true, inclusion: { in: %w[inches centimeters] }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, length: { maximum: 20 }, allow_blank: true

  # Validate measurement values are positive when present
  %w[ankle bicep bottom chest head height hip inseam knee neck outseam shorts
     shoulder sleeve short_sleeve thigh top_length waist wrist].each do |measurement|
    validates measurement.to_sym, numericality: { greater_than: 0 }, allow_blank: true
  end

  # The above in the do and measurement.to_sym makes it so you don't need to write all the below,  :ankle means the ankle column
  # validates :ankle, numericality: { greater_than: 0 }, allow_blank: true
  # validates :bicep, numericality: { greater_than: 0 }, allow_blank: true
  # validates :bottom, numericality: { greater_than: 0 }, allow_blank: true

  # Scopes - These are methods that retrive a subset of the data
  scope :active, -> { where(in_trash: false) }
  scope :trashed, -> { where(in_trash: true) }
  scope :male, -> { where(gender: "Male") }
  scope :female, -> { where(gender: "Female") }

  # Callbacks
  before_validation :set_defaults
  before_save :convert_measurements_to_cm

  # Class methods
  def self.bulk_soft_delete(client_ids)
    where(id: client_ids).update_all(in_trash: true, updated_at: Time.current)
  end

  # Instance methods
  def soft_delete!
    update!(in_trash: true)
  end

  def restore!
    update!(in_trash: false)
  end

  def custom_field_value(custom_field)
    client_custom_field_values.find_by(custom_field: custom_field)&.value
  end

  def set_custom_field_value(custom_field, value)
    ccfv = client_custom_field_values.find_or_initialize_by(custom_field: custom_field)
    ccfv.value = value
    ccfv.save!
  end

  # Convert measurements for display based on original measurement_unit
  def display_measurements
    measurements = {}
    measurement_fields.each do |field|
      value = send(field)
      next unless value

      measurements[field] = measurement_unit == "inches" ? cm_to_inches(value) : value
    end
    measurements
  end

  private

  def set_defaults
    self.in_trash = false if in_trash.nil? # Sets the trash value to false if it is nil
    self.measurement_unit ||= "centimeters" # Sets the measurement unit to centimeters if it is nil
  end

  def convert_measurements_to_cm
    return unless measurement_unit == "inches" # If it is not inches, do nothing

    # Convert all measurement fields from inches to centimeters

    measurement_fields.each do |field|
      value = public_send(field) # same as self.height
      next unless value && public_send("#{field}_changed?") # check if self.height was modified
      public_send("#{field}=", inches_to_cm(value)) # same as self.height = inches_to_cm(value)
    end
  end

  def measurement_fields
    # %w is used to create an array of strings without needing to quote and comma separate them, if %W is used, you can use variables like #{name} and it would replace whereas %w is just plain strings
    %w[ankle bicep bottom chest head height hip inseam knee neck outseam shorts shoulder sleeve short_sleeve thigh top_length waist wrist]
  end

  def inches_to_cm(inches)
    inches * 2.54
  end

  def cm_to_inches(cm)
    cm / 2.54
  end
end
