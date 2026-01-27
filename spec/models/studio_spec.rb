require 'rails_helper'

RSpec.describe Studio, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:digital_channels).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'uniqueness' do
      # Providing a valid company and name to avoid validation errors on other fields
      subject { create(:studio) }
      it { should validate_uniqueness_of(:handle) }
    end
  end

  describe 'attachments' do
    it 'can have a profile attached' do
      studio = build(:studio)
      expect(studio.profile).to be_an_instance_of(ActiveStorage::Attached::One)
    end

    it 'can have a banner attached' do
      studio = build(:studio)
      expect(studio.banner).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe 'callbacks' do
    describe 'after_commit on create' do
      it 'enqueues CreateQrStudioWorker when a studio is created' do
        expect(CreateQrStudioWorker).to receive(:perform_async).once

        create(:studio)
      end
    end

    describe 'after_commit on update' do
      let!(:studio) { create(:studio) }

      before do
        # Clear any previous calls from the create callback
        allow(CreateQrStudioWorker).to receive(:perform_async)
      end

      context 'when handle is updated' do
        it 'enqueues CreateQrStudioWorker' do
          expect(CreateQrStudioWorker).to receive(:perform_async).with(studio.id).once

          studio.update!(handle: 'new-handle')
        end
      end

      context 'when handle is not updated' do
        it 'does not enqueue CreateQrStudioWorker' do
          expect(CreateQrStudioWorker).not_to receive(:perform_async)

          studio.update!(name: 'Updated Studio Name')
        end
      end

      context 'when other fields are updated along with handle' do
        it 'enqueues CreateQrStudioWorker only once' do
          expect(CreateQrStudioWorker).to receive(:perform_async).with(studio.id).once

          studio.update!(handle: 'another-new-handle', description: 'Updated description')
        end
      end
    end
  end
end
