FactoryBot.define do
  factory :digital_channel do
    studio
    channel_type { DigitalChannel.channel_types.keys.sample }
    value { Faker::Internet.url }
  end
end
