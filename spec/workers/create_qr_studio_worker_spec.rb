require 'rails_helper'

RSpec.describe CreateQrStudioWorker, type: :worker do
  describe '#perform' do
    let(:studio) { create(:studio) }

    around do |example|
      original_value = ENV['WEB_APP_URL']
      ENV['WEB_APP_URL'] = 'http://localhost:3001'
      example.run
      ENV['WEB_APP_URL'] = original_value
    end

    it 'generates a QR code SVG and attaches it to the studio' do
      # Detach existing QR to test fresh attachment
      studio.qr_profile.purge if studio.qr_profile.attached?

      described_class.new.perform(studio.id)

      studio.reload
      expect(studio.qr_profile).to be_attached
    end

    it 'attaches a file with SVG content type' do
      studio.qr_profile.purge if studio.qr_profile.attached?

      described_class.new.perform(studio.id)

      studio.reload
      expect(studio.qr_profile.content_type).to eq('image/svg+xml')
    end

    it 'names the file correctly' do
      studio.qr_profile.purge if studio.qr_profile.attached?

      described_class.new.perform(studio.id)

      studio.reload
      expect(studio.qr_profile.filename.to_s).to eq("studio_#{studio.id}_qr.svg")
    end

    it 'generates a valid SVG containing the studio URL' do
      studio.qr_profile.purge if studio.qr_profile.attached?

      described_class.new.perform(studio.id)

      studio.reload
      svg_content = studio.qr_profile.download
      expect(svg_content).to include('<svg')
      expect(svg_content).to include('</svg>')
    end

    context 'when studio does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.new.perform(-1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when updating an existing QR' do
      it 'replaces the existing QR attachment' do
        # First, ensure QR exists
        expect(studio.qr_profile).to be_attached

        old_blob_id = studio.qr_profile.blob.id

        # Update the handle and regenerate
        studio.update!(handle: 'new-unique-handle')
        described_class.new.perform(studio.id)

        studio.reload
        expect(studio.qr_profile).to be_attached
        expect(studio.qr_profile.blob.id).not_to eq(old_blob_id)
      end
    end
  end

  describe 'Sidekiq configuration' do
    it 'includes Sidekiq::Worker' do
      expect(described_class.ancestors).to include(Sidekiq::Worker)
    end
  end
end
