class Branch < ApplicationRecord
  has_many :rooms, dependent: :destroy
  has_many :schedules, dependent: :destroy
  belongs_to :studio

  has_many_attached :images do |attachable|
    # Variante estándar para la galería
    attachable.variant :display, resize_to_limit: [1200, 1200], format: :webp, saver: { quality: 80 }, preprocessed: true

    # Variante móvil (optimizada para dispositivos)
    attachable.variant :mobile, resize_to_limit: [800, 800], format: :webp, saver: { quality: 75 }, preprocessed: true
  end

  validates :name, :phone, :email, :address, :timezone, presence: true
  validates :images,
            attached: true,
            content_type: [:png, :jpg, :jpeg, :webp],
            size: { less_than: 10.megabytes },
            limit: { min: 1, max: 10 }

  accepts_nested_attributes_for :rooms
  accepts_nested_attributes_for :schedules

  def archive
    update(active: false)
  end
end
