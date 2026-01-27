class Api::V1::RoomSerializer < ActiveModel::Serializer
  attributes :id, :name, :capacity, :layout
end
