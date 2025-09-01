FactoryBot.define do
  factory :custom_field do
    sequence(:field_name) { |n| "Custom Field #{n}" }
    field_type { "measurement" }
    is_active { true }
  end
end
