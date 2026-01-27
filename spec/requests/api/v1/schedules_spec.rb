require 'rails_helper'

RSpec.describe "Api::V1::Schedules", type: :request do
  let!(:user) { create(:user, :with_company) }
  let(:company) { user.companies.first }
  let!(:studio) { create(:studio, company: company) }
  let!(:branch) { create(:branch, studio: studio) }
  let(:headers) { auth_headers(user, company.id).merge('Current-Studio-Id' => studio.id.to_s) }
  let!(:schedules) { create_list(:schedule, 3, branch: branch) }
  let(:schedule_id) { schedules.first.id }

  before do
    user.mark_as_verified!
  end

  describe "GET /api/branches/:branch_id/schedules/:id" do
    before { get "/api/branches/#{branch.id}/schedules/#{schedule_id}", headers: headers }

    context "when the record exists" do
      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the schedule" do
        expect(JSON.parse(response.body)['schedule']['id']).to eq(schedule_id)
      end
    end
  end

  describe "PATCH /api/branches/:branch_id/schedules/:id" do
    let(:valid_attributes) { { schedule: { start_time: '10:00:00' } } }

    it "updates the record" do
      patch "/api/branches/#{branch.id}/schedules/#{schedule_id}", params: valid_attributes.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['schedule']['start_time']).to include('10:00:00')
    end
  end
end
