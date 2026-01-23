require 'rails_helper'

RSpec.describe "Api::V1::Studios", type: :request do
  let!(:user) { create(:user, :with_company) }
  let(:company) { user.companies.first }
  let(:headers) { auth_headers(user, company.id) }
  let!(:studios) { create_list(:studio, 3, company: company) }
  let(:studio_id) { studios.first.id }

  before do
    user.mark_as_verified!
  end

  let!(:digital_channel) { create(:digital_channel, studio: studios.first) }

  describe "GET /api/studios" do
    context "when the request is valid" do
      it "returns status code 200" do
        get "/api/studios", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['studios'].size).to eq(3)
      end
    end
  end

  describe "GET /api/studios/:id" do
    before { get "/api/studios/#{studio_id}", headers: headers }

    context "when the record exists" do
      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the studio" do
        expect(JSON.parse(response.body)['studio']['id']).to eq(studio_id)
      end
    end

    context "when the record does not exist" do
      let(:studio_id) { 100 }

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/studios" do
    let(:valid_attributes) do
      {
        studio: {
          name: 'New Studio',
          handle: 'new-studio',
          description: 'A brand new studio',
          profile: fixture_file_upload('spec/fixtures/files/square.png', 'image/png'),
          banner: fixture_file_upload('spec/fixtures/files/banner.png', 'image/png'),
          digital_channels_attributes: [
            { channel_type: 'whatsapp', value: '123456789' },
            { channel_type: 'instagram', value: '@newstudio' }
          ]
        }
      }
    end

    context "when the request is valid" do
      before { post "/api/studios", params: valid_attributes, headers: headers }

      it "creates a studio" do
        expect(JSON.parse(response.body)['studio']['name']).to eq('New Studio')
      end

      it "returns status code 201" do
        expect(response).to have_http_status(:created)
      end

      it "creates associated digital channels" do
        expect(JSON.parse(response.body)['studio']['digital_channels'].size).to eq(2)
      end
    end

    context "when the request is invalid" do
      before { post "/api/studios", params: { studio: { name: nil } }.to_json, headers: headers }

      it "returns status code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a validation failure message" do
        expect(response.body).to match(/Name can't be blank/)
      end
    end
  end

  describe "PATCH /api/studios/:id" do
    let(:valid_attributes) { { studio: { name: 'Updated Name' } } }

    context "when the record exists" do
      before { patch "/api/studios/#{studio_id}", params: valid_attributes.to_json, headers: headers }

      it "updates the record" do
        expect(JSON.parse(response.body)['studio']['name']).to eq('Updated Name')
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when updating nested digital channels" do
      it "updates an existing digital channel" do
        patch "/api/studios/#{studio_id}",
              params: {
                studio: {
                  digital_channels_attributes: [
                    { id: digital_channel.id, value: 'updated-value' }
                  ]
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)
        expect(digital_channel.reload.value).to eq('updated-value')
      end

      it "creates a new digital channel when id is missing" do
        expect {
          patch "/api/studios/#{studio_id}",
                params: {
                  studio: {
                    digital_channels_attributes: [
                      { channel_type: 'facebook', value: 'new-fb-page' }
                    ]
                  }
                }.to_json,
                headers: headers
        }.to change(DigitalChannel, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['studio']['digital_channels'].any? { |dc| dc['value'] == 'new-fb-page' }).to be true
      end

      it "deletes a digital channel when _destroy is sent" do
        expect {
          patch "/api/studios/#{studio_id}",
                params: {
                  studio: {
                    digital_channels_attributes: [
                      { id: digital_channel.id, _destroy: '1' }
                    ]
                  }
                }.to_json,
                headers: headers
        }.to change(DigitalChannel, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
