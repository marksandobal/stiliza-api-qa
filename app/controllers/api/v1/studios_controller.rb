class Api::V1::StudiosController < Api::V1::BaseController
  before_action :find_studio, only: [:show, :update]

  def index
    studios = @current_company.studios
                              .with_attached_profile
                              .with_attached_banner
                              .with_attached_qr_profile
    render json: studios, each_serializer: Api::V1::StudioSerializer, status: :ok
  end

  def show
    render json: @studio, serializer: Api::V1::StudioSerializer, status: :ok
  end

  def create
    studio = @current_company.studios.new(studio_params)
    if studio.save
      render json: studio, serializer: Api::V1::StudioSerializer, status: :created
    else
      render json: { errors: studio.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def update
    @studio.update!(studio_params)
    render json: @studio, serializer: Api::V1::StudioSerializer, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  private

  def studio_params
    params.require(:studio).permit(:name, :description, :profile, :banner,
      digital_channels_attributes: [:id, :channel_type, :value, :_destroy])
  end

  def find_studio
    @studio = @current_company.studios.find(params[:id])

  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
