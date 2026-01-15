module Api
  module V1
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :email, :verified

      attribute(:verified_at) { object.created_at.iso8601 }
      attribute(:created_at) { object.created_at.iso8601 }

      has_many :companies, serializer: Api::V1::CompanySerializer
      has_one :user_profile, serializer: Api::V1::UserProfileSerializer
    end
  end
end
