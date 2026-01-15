require 'rails_helper'

RSpec.describe 'Users::Verification', type: :request do
  let(:user) { create(:user, :unverified) }
  let(:verified_user) { create(:user, :verified) }
  let(:expired_code_user) { create(:user, :with_expired_code) }

  describe 'POST /users/verification' do
    context 'with valid verification code' do
      it 'returns success status' do
        post '/users/verification', params: {
          email: user.email,
          code: user.verification_code
        }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        post '/users/verification', params: {
          email: user.email,
          code: user.verification_code
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Account successfully verified.')
      end

      it 'marks the user as verified' do
        post '/users/verification', params: {
          email: user.email,
          code: user.verification_code
        }, as: :json

        user.reload
        expect(user.verified).to be_truthy
      end

      it 'sets verified_at timestamp' do
        post '/users/verification', params: {
          email: user.email,
          code: user.verification_code
        }, as: :json

        user.reload
        expect(user.verified_at).to be_present
      end

      it 'clears the verification code' do
        post '/users/verification', params: {
          email: user.email,
          code: user.verification_code
        }, as: :json

        user.reload
        expect(user.verification_code).to be_nil
      end
    end

    context 'with invalid verification code' do
      it 'returns unprocessable entity status' do
        post '/users/verification', params: {
          email: user.email,
          code: 'wrong_code'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        post '/users/verification', params: {
          email: user.email,
          code: 'wrong_code'
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid verification code.')
      end

      it 'does not mark the user as verified' do
        post '/users/verification', params: {
          email: user.email,
          code: 'wrong_code'
        }, as: :json

        user.reload
        expect(user.verified).to be_falsey
      end
    end

    context 'with expired verification code' do
      before do
        expired_code_user.update verification_sent_at: 2.days.ago
      end

      it 'returns unprocessable entity status' do
        post '/users/verification', params: {
          email: expired_code_user.email,
          code: expired_code_user.verification_code
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('The code has expired. Please request a new one.')
      end

      it 'does not mark the user as verified' do
        post '/users/verification', params: {
          email: expired_code_user.email,
          code: expired_code_user.verification_code
        }, as: :json

        expired_code_user.reload
        expect(expired_code_user.verified).to be_falsey
      end
    end

    context 'with non-existent email' do
      it 'returns unprocessable entity status' do
        post '/users/verification', params: {
          email: 'nonexistent@example.com',
          code: '123456'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        post '/users/verification', params: {
          email: 'nonexistent@example.com',
          code: '123456'
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid verification code.')
      end
    end

    context 'with missing parameters' do
      it 'returns error when email is missing' do
        post '/users/verification', params: {
          code: user.verification_code
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error when code is missing' do
        post '/users/verification', params: {
          email: user.email
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /users/resend_verification' do
    context 'with valid unverified user' do
      it 'returns success status' do
        post '/users/resend_verification', params: {
          email: user.email
        }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        post '/users/resend_verification', params: {
          email: user.email
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('A new verification code has been sent.')
      end

      it 'generates a new verification code' do
        old_code = user.verification_code

        post '/users/resend_verification', params: {
          email: user.email
        }, as: :json

        user.reload
        expect(user.verification_code).not_to eq(old_code)
        expect(user.verification_code).to be_present
      end

      it 'updates verification_sent_at timestamp' do
        old_timestamp = user.verification_sent_at

        # Wait a moment to ensure timestamp difference
        sleep 0.1

        post '/users/resend_verification', params: {
          email: user.email
        }, as: :json

        user.reload
        expect(user.verification_sent_at).to be > old_timestamp
      end

      it 'queues a verification email' do
        expect {
          post '/users/resend_verification', params: {
            email: user.email
          }, as: :json
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'with already verified user' do
      before do
        verified_user.mark_as_verified!
        verified_user.reload
      end

      it 'returns unprocessable entity status' do
        post '/users/resend_verification', params: {
          email: verified_user.email
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        post '/users/resend_verification', params: {
          email: verified_user.email
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('User not found or already verified.')
      end

      it 'does not send verification email' do
        expect {
          post '/users/resend_verification', params: {
            email: verified_user.email
          }, as: :json
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'with non-existent user' do
      it 'returns unprocessable entity status' do
        post '/users/resend_verification', params: {
          email: 'nonexistent@example.com'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        post '/users/resend_verification', params: {
          email: 'nonexistent@example.com'
        }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('User not found or already verified.')
      end

      it 'does not send verification email' do
        expect {
          post '/users/resend_verification', params: {
            email: 'nonexistent@example.com'
          }, as: :json
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'with expired verification code' do
      it 'generates a new code' do
        old_code = expired_code_user.verification_code

        post '/users/resend_verification', params: {
          email: expired_code_user.email
        }, as: :json

        expired_code_user.reload
        expect(expired_code_user.verification_code).not_to eq(old_code)
      end

      it 'returns success status' do
        post '/users/resend_verification', params: {
          email: expired_code_user.email
        }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with missing email parameter' do
      it 'returns unprocessable entity status' do
        post '/users/resend_verification', params: {}, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
