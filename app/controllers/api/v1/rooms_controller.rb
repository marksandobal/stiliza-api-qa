class Api::V1::RoomsController < Api::V1::BaseController
  before_action :set_current_studio!
  before_action :find_branch!
  before_action :find_room, only: [:show, :update, :destroy]

  def show
    render json: @room, serializer: Api::V1::RoomSerializer
  end

  def create
    @room = @branch.rooms.new(room_params)
    if @room.save
      render json: @room, serializer: Api::V1::RoomSerializer, status: :created
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      render json: @room, serializer: Api::V1::RoomSerializer
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @room.archive
    render json: { message: "Room archived successfully" }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def find_branch!
    @branch = @current_studio.branches.find(params[:branch_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def find_room
    @room = @branch.rooms.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def room_params
    params.require(:room).permit(:name, :capacity, :layout)
  end
end
