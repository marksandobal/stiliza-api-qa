class Room < ApplicationRecord
  belongs_to :branch

  validates :name, presence: true
  validates :capacity, presence: true
  validates :layout, presence: true

  scope :active, -> { where(active: true) }

  def archive
    update(active: false)
  end
end
