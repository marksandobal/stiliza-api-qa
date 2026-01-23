require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:last_name) }

    describe 'gender enum' do
      it { should define_enum_for(:gender).with_values(unknown: 0, male: 1, female: 2) }
    end
  end

  describe '#full_name' do
    it 'returns the correct full name' do
      profile = build(:user_profile, name: 'John', last_name: 'Doe', second_last_name: 'Smith')
      expect(profile.full_name).to eq('John Doe Smith')
    end

    it 'handles missing second last name' do
      profile = build(:user_profile, name: 'John', last_name: 'Doe', second_last_name: nil)
      expect(profile.full_name).to eq('John Doe')
    end
  end
end
