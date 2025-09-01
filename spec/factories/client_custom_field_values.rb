FactoryBot.define do
  factory :client_custom_field_value do
    association :client
    association :custom_field
    value { "Sample custom value" }
  end
end
