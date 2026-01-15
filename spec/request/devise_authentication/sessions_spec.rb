require 'rails_helper'

RSpec.describe 'Users::Sessions', type: :request do
  let(:password) { 'Password123!' }
  let(:verified_user) { create(:user, password: password, password_confirmation: password) }
  let(:unverified_user) { create(:user, :unverified, password: password, password_confirmation: password) }

  describe 'POST /login' do
    context 'with valid credentials and verified user' do
      it 'returns success status' do
        verified_user.mark_as_verified!
        verified_user.reload
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: password
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        verified_user.mark_as_verified!
        verified_user.reload
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: password
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['meta']['message']).to eq('Login successful')
      end

      it 'returns user data' do
        verified_user.mark_as_verified!
        verified_user.reload
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: password
          }
        }, as: :json

        json_response = JSON.parse(response.body)

        expect(json_response['user']).to have_key('id')
        expect(json_response['user']).to have_key('email')
      end

      it 'returns JWT token in Authorization header' do
        verified_user.mark_as_verified!
        verified_user.reload
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: password
          }
        }, as: :json

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to match(/^Bearer .+/)
      end

      it 'increments sign_in_count' do
        verified_user.mark_as_verified!
        verified_user.reload
        expect {
          post '/login', params: {
            user: {
              email: verified_user.email,
              password: password
            }
          }, as: :json
          verified_user.reload
        }.to change(verified_user, :sign_in_count).by(1)
      end

      it 'updates current_sign_in_at' do
        verified_user.mark_as_verified!
        verified_user.reload
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: password
          }
        }, as: :json

        verified_user.reload
        expect(verified_user.current_sign_in_at).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: 'WrongPassword123!'
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: 'WrongPassword123!'
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid credentials')
      end

      it 'does not return JWT token' do
        post '/login', params: {
          user: {
            email: verified_user.email,
            password: 'WrongPassword123!'
          }
        }, as: :json

        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'with non-existent email' do
      it 'returns unauthorized status' do
        post '/login', params: {
          user: {
            email: 'nonexistent@example.com',
            password: password
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        post '/login', params: {
          user: {
            email: 'nonexistent@example.com',
            password: password
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid credentials')
      end
    end

    context 'with unverified user' do
      it 'returns forbidden status' do
        post '/login', params: {
          user: {
            email: unverified_user.email,
            password: password
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a verification error message' do
        post '/login', params: {
          user: {
            email: unverified_user.email,
            password: password
          }
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Your account is not activated yet.')
      end

      it 'does not return JWT token' do
        post '/login', params: {
          user: {
            email: unverified_user.email,
            password: password
          }
        }, as: :json

        expect(response.headers['Authorization']).to be_nil
        expect(JSON.parse(response.body)).to eq({ "error" => "Your account is not activated yet." })
      end

      it 'does not increment sign_in_count' do
        expect {
          post '/login', params: {
            user: {
              email: unverified_user.email,
              password: password
            }
          }, as: :json
          unverified_user.reload
        }.not_to change(unverified_user, :sign_in_count)
      end
    end

    context 'with missing parameters' do
      it 'returns unauthorized when email is missing' do
        post '/login', params: {
          user: {
            password: password
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized when password is missing' do
        post '/login', params: {
          user: {
            email: verified_user.email
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
