require 'rails_helper'

RSpec.describe "Api::V1::Branches", type: :request do
  let!(:user) { create(:user, :with_company) }
  let(:company) { user.companies.first }
  let!(:studio) { create(:studio, company: company) }
  let(:headers) { auth_headers(user, company.id).merge('Current-Studio-Id' => studio.id.to_s) }
  let!(:branches) { create_list(:branch, 3, studio: studio) }
  let(:branch_id) { branches.first.id }

  before do
    user.mark_as_verified!
  end

  describe "GET /api/branches" do
    it "returns status code 200" do
      get "/api/branches", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['branches'].size).to eq(3)
    end
  end

  describe "GET /api/branches/:id" do
    before { get "/api/branches/#{branch_id}", headers: headers }

    context "when the record exists" do
      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the branch" do
        expect(JSON.parse(response.body)['branch']['id']).to eq(branch_id)
      end
    end

    context "when the record does not exist" do
      let(:branch_id) { 100 }

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/branches" do
    let(:valid_attributes) do
      {
        branch: {
          name: 'New Branch',
          phone: '1234567890',
          email: 'branch@example.com',
          address: '123 Main St',
          timezone: 'America/Mexico_City',
          images: [fixture_file_upload('spec/fixtures/files/square.png', 'image/png')]
        }
      }
    end

    context "when the request is valid" do
      it "creates a branch" do
        expect {
          post "/api/branches", params: valid_attributes, headers: headers
        }.to change(Branch, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['branch']['name']).to eq('New Branch')
      end
    end

    context "with all permitted parameters (nested attributes)" do
      let(:complex_attributes) do
        {
          branch: {
            name: 'Complex Branch',
            phone: '5551234567',
            email: 'complex@branch.com',
            address: '456 Complex Ave',
            latitude: 19.4326,
            longitude: -99.1332,
            timezone: 'America/Mexico_City',
            active: true,
            images: [fixture_file_upload('spec/fixtures/files/square.png', 'image/png')],
            rooms_attributes: [
              { name: 'VIP Room', capacity: 2, layout: 'Lounge' },
              { name: 'Standard Room', capacity: 5, layout: 'Classroom' }
            ],
            schedules_attributes: [
              { day_of_week: 'monday', start_time: '08:00:00', end_time: '17:00:00', active: true },
              { day_of_week: 'tuesday', start_time: '08:00:00', end_time: '17:00:00', active: true }
            ]
          }
        }
      end

      it "creates a branch with rooms and schedules" do
        expect {
          post "/api/branches", params: complex_attributes, headers: headers
        }.to change(Branch, :count).by(1)
          .and change(Room, :count).by(2)
          .and change(Schedule, :count).by(2)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)['branch']

        # Validate parent fields
        expect(json_response['name']).to eq('Complex Branch')
        expect(json_response['phone']).to eq('5551234567')
        expect(json_response['email']).to eq('complex@branch.com')
        expect(json_response['address']).to eq('456 Complex Ave')
        expect(json_response['latitude'].to_f).to eq(19.4326)
        expect(json_response['longitude'].to_f).to eq(-99.1332)
        expect(json_response['timezone']).to eq('America/Mexico_City')
        expect(json_response['active']).to be true

        # Validate nested objects are returned (thanks to the serializer updates)
        expect(json_response['rooms'].size).to eq(2)
        expect(json_response['schedules'].size).to eq(2)
      end
    end

    context "when the request is invalid" do
      it "returns status code 422" do
        post "/api/branches", params: { branch: { name: nil } }.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /api/branches/:id" do
    let(:valid_attributes) { { branch: { name: 'Updated Branch Name' } } }

    context "when the record exists" do
      it "updates the record" do
        patch "/api/branches/#{branch_id}", params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['branch']['name']).to eq('Updated Branch Name')
      end
    end
  end

  describe "DELETE /api/branches/:id" do
    it "archives the branch" do
      delete "/api/branches/#{branch_id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(branches.first.reload.active).to be false
    end
  end
end
