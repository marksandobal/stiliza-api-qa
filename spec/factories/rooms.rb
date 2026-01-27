FactoryBot.define do
  factory :room do
    branch
    name { Faker::Commerce.product_name }
    capacity { rand(1..10) }
    layout { 'Standard' }
    active { true }
  end
end
