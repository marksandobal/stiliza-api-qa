FactoryBot.define do
  factory :schedule do
    branch
    sequence(:day_of_week) { |n| Schedule.day_of_weeks.keys[n % 7] }
    start_time { '09:00:00' }
    end_time { '18:00:00' }
    active { true }
  end
end
