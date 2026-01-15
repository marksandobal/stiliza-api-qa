class UserMailer < ApplicationMailer
  layout "users/mailer"

  def verification_email(user)
    @user = user
    mail(to: @user.email, subject: "Código de verificación de Stiliza")
  end

  def password_changed(user)
    @user = user
    mail(to: @user.email, subject: "Seguridad: Tu contraseña ha sido cambiada")
  end
end
