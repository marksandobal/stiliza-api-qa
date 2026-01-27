class Api::V1::ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :day_of_week, :start_time, :end_time, :active, :branch_id
end
