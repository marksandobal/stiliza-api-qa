require 'rails_helper'

RSpec.describe 'Users::Passwords', type: :request do
  let!(:user) { create(:user, :verified, :with_profile) }

  describe 'POST /password' do
    context 'with valid email' do
      it 'returns success status' do
        post '/password', params: {
          user: {
            email: user.email
          }
        }, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'sends password reset email' do
        expect {
            post '/password', params: {
              user: { email: user.email }
            }, as: :json
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'generates reset_password_token' do
        post '/password', params: {
          user: {
            email: user.email
          }
        }, as: :json

        user.reload
        expect(user.reset_password_token).to be_present
      end

      it 'sets reset_password_sent_at' do
        post '/password', params: {
          user: {
            email: user.email
          }
        }, as: :json

        user.reload
        expect(user.reset_password_sent_at).to be_present
      end
    end

    context 'with non-existent email' do
      it 'returns success status (security measure)' do
        post '/password', params: {
          user: {
            email: 'nonexistent@example.com'
          }
        }, as: :json

        # Devise returns success even for non-existent emails to prevent email enumeration
        expect(response).to have_http_status(:created)
      end

      it 'does not send password reset email' do
        expect {
          post '/password', params: {
            user: {
              email: 'nonexistent@example.com'
            }
          }, as: :json
          }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end

  describe 'PUT /password' do
    let(:reset_token) { user.send_reset_password_instructions }

    context 'with valid token and passwords' do
      it 'returns success status' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Password updated successfully')
      end

      it 'updates the user password' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        user.reload
        expect(user.valid_password?('NewPassword123!')).to be_truthy
      end

      it 'clears the reset_password_token' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        user.reload
        expect(user.reset_password_token).to be_nil
      end

      it 'invalidates existing JWT tokens' do
        original_updated_at = user.updated_at

        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        user.reload
        expect(user.updated_at).to be > original_updated_at
      end
    end

    context 'with invalid token' do
      it 'returns unprocessable entity status' do
        put '/password', params: {
          user: {
            reset_password_token: 'invalid_token',
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put '/password', params: {
          user: {
            reset_password_token: 'invalid_token',
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'with mismatched passwords' do
      it 'returns unprocessable entity status' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'DifferentPassword123!'
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'DifferentPassword123!'
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to include(match(/password confirmation/i))
      end

      it 'does not update the password' do
        original_password = user.encrypted_password

        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'DifferentPassword123!'
          }
        }, as: :json

        user.reload
        expect(user.encrypted_password).to eq(original_password)
      end
    end

    context 'with weak password' do
      it 'returns unprocessable entity status' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'short',
            password_confirmation: 'short'
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put '/password', params: {
          user: {
            reset_password_token: reset_token,
            password: 'short',
            password_confirmation: 'short'
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'with expired token' do
      it 'returns unprocessable entity status when token is expired' do
        raw_token = user.send_reset_password_instructions

        User.where(id: user.id).update_all(reset_password_sent_at: 10.hours.ago)

        put '/password', params: {
          user: {
            reset_password_token: raw_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!',
            email: user.email
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to include(match(/expired|caducado/i))
      end
    end
  end
end
