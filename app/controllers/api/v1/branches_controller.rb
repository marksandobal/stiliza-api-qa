class Api::V1::BranchesController < Api::V1::BaseController
  before_action :set_current_studio!
  before_action :find_branch, only: [:show, :update, :destroy]

  def index
    @branches = @current_studio.branches.all
    render json: @branches, each_serializer: Api::V1::BranchSerializer
  end

  def show
    render json: @branch, serializer: Api::V1::BranchSerializer
  end

  def create
    @branch = @current_studio.branches.new(branch_params)
    if @branch.save
      render json: @branch, serializer: Api::V1::BranchSerializer, status: :created
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  def update
    if @branch.update(branch_update_params)
      render json: @branch, serializer: Api::V1::BranchSerializer
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @branch.archive
    render json: { message: "Branch archived successfully" }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def find_branch
    @branch = @current_studio.branches.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def branch_params
    params.require(:branch)
          .permit(:name, :phone, :email, :address, :latitude, :longitude, :timezone, :active,
                  images: [],
                  rooms_attributes: [:id, :name, :capacity, :layout],
                  schedules_attributes: [:id, :day_of_week, :start_time, :end_time, :active])
  end

  def branch_update_params
    params.require(:branch)
          .permit(:name, :phone, :email, :address, :latitude, :longitude, :timezone, :active,
                  images: [])
  end
end
