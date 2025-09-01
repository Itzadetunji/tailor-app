# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a default user for seeding
user = User.find_or_create_by!(email: 'demo@example.com') do |u|
  u.first_name = 'Demo'
  u.last_name = 'User'
end

puts "Created or found user: #{user.email}"

# Create some sample custom fields
custom_fields = [
  { field_name: 'Collar Width', field_type: 'measurement' },
  { field_name: 'Cuff Length', field_type: 'measurement' },
  { field_name: 'Trouser Rise', field_type: 'measurement' },
  { field_name: 'Jacket Vents', field_type: 'text' },
  { field_name: 'Fabric Preference', field_type: 'text' }
]

custom_fields.each do |field_attrs|
  CustomField.find_or_create_by!(field_name: field_attrs[:field_name]) do |field|
    field.field_type = field_attrs[:field_type]
    field.is_active = true
  end
end

puts "Created #{CustomField.count} custom fields"

# Create some sample clients
clients_data = [
  {
    name: 'John Doe',
    gender: 'Male',
    measurement_unit: 'inches',
    email: 'john.doe@example.com',
    phone_number: '+1234567890',
    chest: 42.0,
    waist: 32.0,
    height: 72.0,
    shoulder: 18.0,
    sleeve: 25.0
  },
  {
    name: 'Jane Smith',
    gender: 'Female',
    measurement_unit: 'centimeters',
    email: 'jane.smith@example.com',
    phone_number: '+0987654321',
    chest: 95.0,
    waist: 75.0,
    height: 165.0,
    hip: 98.0
  },
  {
    name: 'Robert Johnson',
    gender: 'Male',
    measurement_unit: 'inches',
    email: 'robert.johnson@example.com',
    chest: 44.0,
    waist: 36.0,
    height: 74.0,
    shoulder: 19.0,
    sleeve: 26.0,
    neck: 16.5
  }
]

clients_data.each do |client_attrs|
  client = user.clients.find_or_create_by!(email: client_attrs[:email]) do |c|
    client_attrs.each { |key, value| c.send("#{key}=", value) }
  end
  
  # Add some custom field values
  if client.persisted?
    collar_width_field = CustomField.find_by(field_name: 'Collar Width')
    fabric_preference_field = CustomField.find_by(field_name: 'Fabric Preference')
    
    if collar_width_field && client.measurement_unit == 'inches'
      client.set_custom_field_value(collar_width_field, '15.5')
    end
    
    if fabric_preference_field
      preferences = ['Cotton', 'Wool', 'Linen', 'Silk']
      client.set_custom_field_value(fabric_preference_field, preferences.sample)
    end
  end
end

puts "Created #{Client.count} clients for user #{user.email}"
