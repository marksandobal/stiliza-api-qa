require 'rails_helper'

RSpec.describe 'Users::Registrations', type: :request do
  let(:valid_attributes) do
    {
      user: {
        email: 'test@example.com',
        password: 'Password123!',
        password_confirmation: 'Password123!',
        role: 'admin',
        company_attributes: {
          name: 'Test Company'
        }
      }
    }
  end

  let(:valid_attributes_without_company) do
    {
      user: {
        email: 'test@example.com',
        password: 'Password123!',
        password_confirmation: 'Password123!'
      }
    }
  end

  let(:invalid_attributes) do
    {
      user: {
        email: 'invalid-email',
        password: 'short',
        password_confirmation: 'short'
      }
    }
  end

  describe 'POST /signup' do
    context 'with valid parameters and company' do
      it 'creates a new user' do
        expect {
          post '/signup', params: valid_attributes, as: :json
        }.to change(User, :count).by(1)
      end

      it 'creates a new company' do
        expect {
          post '/signup', params: valid_attributes, as: :json
        }.to change(Company, :count).by(1)
      end

      it 'creates a company_user association' do
        expect {
          post '/signup', params: valid_attributes, as: :json
        }.to change(CompanyUser, :count).by(1)
      end

      it 'assigns the correct role to the user' do
        post '/signup', params: valid_attributes, as: :json
        user = User.last
        company_user = user.company_users.first
        expect(company_user.role).to eq('admin')
      end

      it 'queues a verification email' do
        expect {
          post '/signup', params: valid_attributes, as: :json
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with('UserMailer', 'verification_email', 'deliver_now', { args: [User] })
      end

      it 'returns a success message' do
        post '/signup', params: valid_attributes, as: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User created successfully')
      end

      it 'generates a verification code' do
        post '/signup', params: valid_attributes, as: :json
        user = User.last
        expect(user.verification_code).not_to be_nil
        expect(user.verification_code.length).to eq(6)
      end

      it 'sets verified to false' do
        post '/signup', params: valid_attributes, as: :json
        user = User.last
        expect(user.verified).to be_falsey
      end
    end

    context 'with valid parameters without company' do
      it 'creates a new user' do
        expect {
          post '/signup', params: valid_attributes_without_company, as: :json
        }.to change(User, :count).by(1)
      end

      it 'does not create a company' do
        expect {
          post '/signup', params: valid_attributes_without_company, as: :json
        }.not_to change(Company, :count)
      end

      it 'does not create a company_user association' do
        expect {
          post '/signup', params: valid_attributes_without_company, as: :json
        }.not_to change(CompanyUser, :count)
      end

      it 'returns a success message' do
        post '/signup', params: valid_attributes_without_company, as: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User created successfully')
      end
    end

    context 'with invalid email' do
      it 'does not create a new user' do
        expect {
          post '/signup', params: invalid_attributes, as: :json
        }.not_to change(User, :count)
      end

      it 'returns validation errors' do
        post '/signup', params: invalid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'with duplicate email' do
      before do
        create(:user, email: 'duplicate@example.com')
      end

      it 'does not create a new user' do
        duplicate_params = valid_attributes.deep_dup
        duplicate_params[:user][:email] = 'duplicate@example.com'

        expect {
          post '/signup', params: duplicate_params, as: :json
        }.not_to change(User, :count)
      end

      it 'returns validation errors' do
        duplicate_params = valid_attributes.deep_dup
        duplicate_params[:user][:email] = 'duplicate@example.com'

        post '/signup', params: duplicate_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include(match(/email/i))
      end
    end

    context 'with missing required fields' do
      it 'returns validation errors when email is missing' do
        params = valid_attributes.deep_dup
        params[:user].delete(:email)

        post '/signup', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end

      it 'returns validation errors when password is missing' do
        params = valid_attributes.deep_dup
        params[:user].delete(:password)

        post '/signup', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'with invalid role' do
      it 'returns an error' do
        params = valid_attributes.deep_dup
        params[:user][:role] = 'invalid_role'
        params[:user][:company_attributes] = { name: 'Test Company' }

        post '/signup', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'when company already exists' do
      let!(:existing_company) { create(:company, name: 'Existing Company') }

      it 'reuses the existing company' do
        params = valid_attributes.deep_dup
        params[:user][:company_attributes][:name] = 'Existing Company'

        expect {
          post '/signup', params: params, as: :json
        }.not_to change(Company, :count)
      end

      it 'creates a company_user association with existing company' do
        params = valid_attributes.deep_dup
        params[:user][:company_attributes][:name] = 'Existing Company'

        post '/signup', params: params, as: :json
        user = User.last
        expect(user.companies).to include(existing_company)
      end
    end
  end
end
