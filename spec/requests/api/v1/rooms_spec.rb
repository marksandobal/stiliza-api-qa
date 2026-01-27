require 'rails_helper'

RSpec.describe "Api::V1::Rooms", type: :request do
  let!(:user) { create(:user, :with_company) }
  let(:company) { user.companies.first }
  let!(:studio) { create(:studio, company: company) }
  let!(:branch) { create(:branch, studio: studio) }
  let(:headers) { auth_headers(user, company.id).merge('Current-Studio-Id' => studio.id.to_s) }
  let!(:rooms) { create_list(:room, 3, branch: branch) }
  let(:room_id) { rooms.first.id }

  before do
    user.mark_as_verified!
  end

  describe "GET /api/branches/:branch_id/rooms/:id" do
    before { get "/api/branches/#{branch.id}/rooms/#{room_id}", headers: headers }

    context "when the record exists" do
      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the room" do
        expect(JSON.parse(response.body)['room']['id']).to eq(room_id)
      end
    end
  end

  describe "POST /api/branches/:branch_id/rooms" do
    let(:valid_attributes) do
      {
        room: {
          name: 'New Room',
          capacity: 5,
          layout: 'Modern'
        }
      }
    end

    context "when the request is valid" do
      it "creates a room" do
        expect {
          post "/api/branches/#{branch.id}/rooms", params: valid_attributes.to_json, headers: headers
        }.to change(Room, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['room']['name']).to eq('New Room')
      end
    end
  end

  describe "PATCH /api/branches/:branch_id/rooms/:id" do
    let(:valid_attributes) { { room: { name: 'Updated Room Name' } } }

    it "updates the record" do
      patch "/api/branches/#{branch.id}/rooms/#{room_id}", params: valid_attributes.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['room']['name']).to eq('Updated Room Name')
    end
  end

  describe "DELETE /api/branches/:branch_id/rooms/:id" do
    it "archives the room" do
      delete "/api/branches/#{branch.id}/rooms/#{room_id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(rooms.first.reload.active).to be false
    end
  end
end
