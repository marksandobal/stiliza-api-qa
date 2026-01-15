# app/controllers/users/verification_controller.rb
class Users::VerificationController < ApplicationController
  def verify
    user = User.find_by(email: params[:email])

    if user && user.verification_code == params[:code]
      if user.verification_code_valid?
        user.mark_as_verified!
        render json: { message: "Account successfully verified." }, status: :ok
      else
        render json: { error: "The code has expired. Please request a new one." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid verification code." }, status: :unprocessable_entity
    end
  end

  def resend
    user = User.find_by(email: params[:email])

    if user && !user.verified
      user.generate_verification_code
      user.save!
      UserMailer.verification_email(user).deliver_later
      render json: { message: "A new verification code has been sent." }, status: :ok
    else
      render json: { error: "User not found or already verified." }, status: :unprocessable_entity
    end
  end
end
