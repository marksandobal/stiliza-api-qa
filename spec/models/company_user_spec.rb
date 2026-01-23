require 'rails_helper'

RSpec.describe CompanyUser, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:company_id) }

    context 'uniqueness' do
      subject { create(:company_user) }
      it { should validate_uniqueness_of(:user_id).scoped_to(:company_id).with_message('is already associated with this company.') }
    end

    describe 'role enum' do
      it { should define_enum_for(:role).with_values(user: 0, coach: 1, admin: 2, super_admin: 3) }
    end
  end
end
