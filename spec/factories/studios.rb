FactoryBot.define do
  factory :studio do
    company
    name { Faker::Company.name }
    description { Faker::Company.catch_phrase }

    after(:build) do |studio|
      studio.profile.attach(io: File.open('spec/fixtures/files/square.png'), filename: 'square.png', content_type: 'image/png')
      studio.banner.attach(io: File.open('spec/fixtures/files/banner.png'), filename: 'banner.png', content_type: 'image/png')
      studio.qr_profile.attach(io: File.open('spec/fixtures/files/square.png'), filename: 'qr.png', content_type: 'image/png')
    end
  end
end
