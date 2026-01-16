# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Deshabilitar callback que falla en API-only
  skip_before_action :verify_signed_out_user, only: :destroy
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    unless resource
      return render json: { error: "Invalid credentials" }, status: :unauthorized
    end

    sign_in(resource_name, resource)

    render json: resource, serializer: Api::V1::UserSerializer, meta: {
      message: "Login successful"
    },  status: :ok
  end

  # DELETE /resource/sign_out
  def destroy
    # Devise-JWT invalida el token vía Warden
    sign_out(resource_name)

    render json: { message: "Logged out successfully" }, status: :ok
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
