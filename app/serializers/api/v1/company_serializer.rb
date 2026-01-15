module Api
  module V1
    class CompanySerializer < ActiveModel::Serializer
      attributes :id, :name, :description
    end
  end
end
