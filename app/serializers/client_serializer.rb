class ClientSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :gender, :measurement_unit, :phone_number, :email,
             :in_trash, :created_at, :updated_at

  # Include all standard measurements, converted to display format
  %w[ankle bicep bottom chest head height hip inseam knee neck outseam shorts
     shoulder sleeve short_sleeve thigh top_length waist wrist].each do |measurement|
    attribute measurement.to_sym do |client|
      value = client.send(measurement)
      next unless value

      client.measurement_unit == "inches" ? (value / 2.54).round(2) : value.to_f
    end
  end

  # Custom field values
  attribute :custom_fields do |client|
    client.client_custom_field_values.includes(:custom_field).map do |ccfv|
      {
        id: ccfv.custom_field.id,
        field_name: ccfv.custom_field.field_name,
        field_type: ccfv.custom_field.field_type,
        value: ccfv.value
      }
    end
  end
end
