FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "John" }
    last_name { "Doe" }
    
    trait :with_name do
      first_name { "Jane" }
      last_name { "Smith" }
    end
  end
end
