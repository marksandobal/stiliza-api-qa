require 'rails_helper'

RSpec.describe DigitalChannel, type: :model do
  describe 'associations' do
    it { should belong_to(:studio) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }

    describe 'channel_type enum' do
      it { should define_enum_for(:channel_type).with_values(whatsapp: 0, instagram: 1, tiktok: 2, facebook: 3) }
    end
  end
end
