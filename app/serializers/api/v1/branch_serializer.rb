class Api::V1::BranchSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone, :email, :address, :latitude, :longitude, :timezone, :active

  has_many :rooms, serializer: Api::V1::RoomSerializer
  has_many :schedules, serializer: Api::V1::ScheduleSerializer
end
