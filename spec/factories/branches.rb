FactoryBot.define do
  factory :branch do
    studio
    name { Faker::Company.name }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    timezone { 'America/Mexico_City' }
    active { true }

    after(:build) do |branch|
      branch.images.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/square.png')),
        filename: 'square.png',
        content_type: 'image/png'
      )
    end
  end
end
