require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  it 'has correct table name' do
    expect(described_class.table_name).to eq('jwt_denylists')
  end
end
