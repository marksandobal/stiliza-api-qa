FactoryBot.define do
  factory :user_profile do
    association :user
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    second_last_name { Faker::Name.last_name }
    gender { [:male, :female, :unknown].sample }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
