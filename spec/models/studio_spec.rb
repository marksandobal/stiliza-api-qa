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
end
