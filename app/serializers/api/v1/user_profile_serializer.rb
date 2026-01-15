module Api
  module V1
    class UserProfileSerializer < ActiveModel::Serializer
      attributes :id, :name, :last_name, :second_last_name, :gender, :birth_date

      def birth_date
        return "" if object.birth_date.blank?

        object.birth_date.strftime("%Y-%m-%d")
      end
    end
  end
end
