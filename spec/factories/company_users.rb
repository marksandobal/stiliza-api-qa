FactoryBot.define do
  factory :company_user do
    association :user
    association :company
    role { :admin }

    trait :member do
      role { :member }
    end

    trait :admin do
      role { :admin }
    end
  end
end
