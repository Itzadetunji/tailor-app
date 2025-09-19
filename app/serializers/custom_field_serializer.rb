class CustomFieldSerializer
  include JSONAPI::Serializer

  attributes :id, :field_name, :field_type, :is_active, :created_at, :updated_at
end
