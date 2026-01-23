class Studio < ApplicationRecord
  # Imagen de Perfil (Redonda en el Front)
  # Usamos un cuadrado perfecto (ej. 400x400) para que con CSS (border-radius: 50%) se vea redonda.
  has_one_attached :profile, dependent: :destroy do |attachable|
    attachable.variant :thumb, resize_to_fill: [500, 500], format: :webp, saver: { quality: 80 }, preprocessed: true
  end

  # Imagen de Banner (Rectangular)
  # Usamos una proporción de aspecto común (ej. 1200x400)
  has_one_attached :banner, dependent: :destroy do |attachable|
    attachable.variant :display, resize_to_fill: [1600, 900], format: :webp, saver: { quality: 80 }, preprocessed: true

    attachable.variant :mobile, resize_to_fill: [800, 450], format: :webp, saver: { quality: 75 }, preprocessed: true
  end

  # QR (Generalmente debe ser nítido, usamos limit para no perder calidad)
  has_one_attached :qr_profile, dependent: :destroy do |attachable|
    attachable.variant :standard, resize_to_limit: [500, 500], format: :png
  end

  belongs_to :company
  has_many :digital_channels, dependent: :destroy

  validates :name, presence: true

  # Validaciones para el Perfil (Foto redonda)
  validates :profile,
            attached: true,
            # aspect_ratio: :square,
            content_type: [:png, :jpg, :jpeg, :webp],
            size: { less_than: 10.megabytes }, # Subimos a 10MB porque las fotos de 48MP pesan
            dimension: {
              width: { min: 400, max: 10000 }, # Permitimos casi cualquier foto de cámara
              height: { min: 400, max: 10000 }
            }

  # Validaciones para el Banner
  validates :banner,
            attached: true,
            # aspect_ratio: :is_16_9,
            content_type: [:png, :jpg, :jpeg, :webp],
            size: { less_than: 15.megabytes },
            dimension: {
              width: { min: 800, max: 10000 }, # El banner debe ser ancho
              height: { min: 300, max: 10000 }
            }

  validates :handle, uniqueness: true, allow_nil: true

  accepts_nested_attributes_for :digital_channels, allow_destroy: true
  before_create :build_handle

  private

  def build_handle
    self.handle = name.downcase.parameterize
  end
end
