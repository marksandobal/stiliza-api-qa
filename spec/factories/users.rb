FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    verified { false }
    verification_code { rand.to_s[2..7] }
    verification_sent_at { Time.current }

    trait :verified do
      verified { true }
      verified_at { Time.current }
      verification_code { nil }
    end

    trait :unverified do
      verified { false }
      verification_code { rand.to_s[2..7] }
      verification_sent_at { Time.current }
    end

    trait :with_expired_code do
      verified { false }
      verification_code { rand.to_s[2..7] }
      verification_sent_at { 2.days.ago }
    end

    trait :with_profile do
      after(:create) do |user|
        create(:user_profile, user: user)
      end
    end

    trait :with_company do
      after(:create) do |user|
        company = create(:company)
        create(:company_user, user: user, company: company, role: :admin)
      end
    end
  end
end
