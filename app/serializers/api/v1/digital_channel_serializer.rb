class Api::V1::DigitalChannelSerializer < ActiveModel::Serializer
  attributes :id, :value, :channel_type
end
