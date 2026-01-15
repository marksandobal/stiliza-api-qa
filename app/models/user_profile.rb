class UserProfile < ApplicationRecord
  belongs_to :user

  enum :gender, {
    unknown: 0, male: 1, female: 2
  }

  validates :name, :last_name, presence: true
  validates :gender, inclusion: { in: genders.keys }

  def full_name
    "#{name} #{last_name} #{second_last_name}".strip!
  end
end
