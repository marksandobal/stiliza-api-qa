require 'rails_helper'

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe 'associations' do
    it { should have_one(:user_profile).dependent(:destroy) }
    it { should have_many(:company_users).dependent(:destroy) }
    it { should have_many(:companies).through(:company_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }

    context 'uniqueness' do
      subject { build(:user) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end
  end

  describe 'devise modules' do
    it { should validate_presence_of(:password) }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:user_profile) }
  end

  describe 'callbacks' do
    it 'generates verification code before create' do
      user = build(:user, verification_code: nil, verification_sent_at: nil)
      expect(user.verification_code).to be_nil
      user.save
      expect(user.verification_code).to be_present
      expect(user.verification_sent_at).to be_present
      expect(user.verified).to be false
    end
  end

  describe '#verification_code_valid?' do
    let(:user) { create(:user) }

    it 'returns true if code was sent recently' do
      user.update(verification_sent_at: 5.minutes.ago)
      expect(user.verification_code_valid?).to be true
    end

    it 'returns false if code has expired' do
      user.update(verification_sent_at: 11.minutes.ago)
      expect(user.verification_code_valid?).to be false
    end

    it 'returns false if verification_sent_at is nil' do
      user.update(verification_sent_at: nil)
      expect(user.verification_code_valid?).to be_falsy
    end
  end

  describe '#mark_as_verified!' do
    let(:user) { create(:user) }

    it 'marks user as verified and clears verification code' do
      user.mark_as_verified!
      expect(user.verified).to be true
      expect(user.verification_code).to be_nil
      expect(user.verified_at).to be_present
    end
  end

  describe '#jwt_subject' do
    let(:user) { create(:user) }

    it 'returns a string with id and updated_at' do
      expect(user.jwt_subject).to eq("#{user.id}-#{user.updated_at.to_i}")
    end
  end

  describe '#active_for_authentication?' do
    let(:user) { create(:user) }

    it 'returns false if not verified' do
      expect(user.active_for_authentication?).to be false
    end

    it 'returns true if verified' do
      user.mark_as_verified!
      expect(user.active_for_authentication?).to be true
    end
  end

  describe '#handle_security_updates' do
    it 'invalidates JWT when password is changed' do
      user = create(:user)
      old_updated_at = user.updated_at

      expect(UserMailer).to receive(:password_changed).with(user).and_return(double(deliver_now: true))

      travel_to 1.day.from_now do
        user.update!(password: 'newpassword123', password_confirmation: 'newpassword123')
      end

      expect(user.reload.updated_at).to be > old_updated_at
    end
  end
end
