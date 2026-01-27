class Schedule < ApplicationRecord
  belongs_to :branch

  validates :day_of_week, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :active, presence: true
  validate :end_after_start

  enum :day_of_week, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }

  private

  def end_after_start
    if start_time >= end_time
      errors.add(:end_time, "must be after start_time")
    end
  end
end
