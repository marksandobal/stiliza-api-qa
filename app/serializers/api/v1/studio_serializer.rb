class Api::V1::StudioSerializer < ActiveModel::Serializer
  # 1. Asegúrate de que los nombres aquí coincidan con los métodos de abajo
  attributes :id, :name, :description, :handle,
             :profile, :banner, :qr_profile_url, :created_at, :updated_at

  has_many :digital_channels, serializer: Api::V1::DigitalChannelSerializer

  def handle
    "#{ENV.fetch("WEB_APP_URL")}/@#{object.handle}" if object.handle.present?
  end

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end

  def profile
    return nil unless object.profile.attached?

    {
      thumb: rails_representation_url(object.profile.variant(:thumb), only_path: false),
      original: rails_representation_url(object.profile, only_path: false)
    }
  end

  def banner
    return nil unless object.banner.attached?

    {
      original: rails_representation_url(object.banner, only_path: false),
      desktop: rails_representation_url(object.banner.variant(:display), only_path: false),
      mobile: rails_representation_url(object.banner.variant(:mobile), only_path: false)
    }
  end

  def qr_profile_url
    return nil unless object.qr_profile.attached?
    rails_representation_url(object.qr_profile.variant(:standard), only_path: false)
  end

  private

  def rails_representation_url(representation, only_path: false)
    # Al configurar default_url_options en los entornos (development.rb, test.rb, etc),
    # Rails manejará el host automáticamente si incluimos los helpers.
    # Pero en serializers, a veces es más explícito usar la config global.
    Rails.application.routes.url_helpers.rails_representation_url(
      representation,
      host: Rails.application.config.action_controller.default_url_options[:host],
      only_path: only_path
    )
  end
end
