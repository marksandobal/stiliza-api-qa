class Api::V1::SchedulesController < Api::V1::BaseController
  before_action :set_current_studio!
  before_action :find_branch!
  before_action :find_schedule, only: [:show, :update]

  def show
    render json: @schedule, serializer: Api::V1::ScheduleSerializer
  end

  def update
    if @schedule.update(schedule_params)
      render json: @schedule, serializer: Api::V1::ScheduleSerializer
    else
      render json: @schedule.errors, status: :unprocessable_entity
    end
  end

  private

  def find_branch!
    @branch = @current_studio.branches.find(params[:branch_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def find_schedule
    @schedule = @branch.schedules.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def schedule_params
    params.require(:schedule).permit(:id, :day_of_week, :start_time, :end_time, :active)
  end
end
