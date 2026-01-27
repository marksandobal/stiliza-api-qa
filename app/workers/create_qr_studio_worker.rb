class CreateQrStudioWorker
  include Sidekiq::Worker

  def perform(studio_id)
    studio = Studio.find(studio_id)
    qr_code = RQRCode::QRCode.new(studio_url(studio))

    svg = qr_code.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 11,
      standalone: true,
      use_path: true
    )

    io = StringIO.new(svg)
    io.class.class_eval { attr_accessor :original_filename, :content_type }
    io.original_filename = "studio_#{studio.id}_qr.svg"
    io.content_type = "image/svg+xml"

    studio.qr_profile.attach(io: io, filename: io.original_filename, content_type: io.content_type)
  end

  private

  def studio_url(studio)
    "#{ENV.fetch("WEB_APP_URL")}/@#{studio.handle}"
  end
end
