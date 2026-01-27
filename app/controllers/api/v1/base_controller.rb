class Api::V1::BaseController < ApplicationController
  # include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_current_company!

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_current_company!
    @current_company = current_user.companies.find_by(id: current_company_id)

    if @current_company.nil?
      render json: {
        error: "Company not found or you do not have access",
        suggestion: "Please select a valid company from your list."
      }, status: :not_found
    end
  end

  def set_current_studio!
    @current_studio = @current_company.studios.find_by(id: current_studio_id)

    if @current_studio.nil?
      render json: {
        error: "Studio not found or you do not have access",
        suggestion: "Please select a valid studio from your list."
      }, status: :not_found
    end
  end

  private

  def user_not_authorized
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end

  def current_company_id
    request.headers["Current-Company-Id"]
  end

  def current_studio_id
    request.headers["Current-Studio-Id"]
  end

  # def authenticate_user!
  #   token = request.headers["Authorization"]&.split(" ")&.last
  #   unless token && valid_token?(token)
  #     render json: { error: "Unauthorized" }, status: :unauthorized
  #   end
  # end

  # def valid_token?(token)
  #   # Logic to validate the token
  #   # This is a placeholder implementation
  #   token == "valid_token_example"
  # end
end
