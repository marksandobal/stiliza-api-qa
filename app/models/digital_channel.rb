class DigitalChannel < ApplicationRecord
  belongs_to :studio

  enum :channel_type, {
    whatsapp: 0,
    instagram: 1,
    tiktok: 2,
    facebook: 3
  }

  validates :channel_type, inclusion: { in: channel_types.keys }
  validates :value, presence: true
end
