require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { should have_many(:company_users).dependent(:destroy) }
    it { should have_many(:users).through(:company_users) }
    it { should have_many(:studios).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
