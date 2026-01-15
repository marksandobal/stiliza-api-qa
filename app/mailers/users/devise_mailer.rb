class Users::DeviseMailer < Devise::Mailer
  layout "users/mailer"
  default template_path: "devise/mailer"

  def reset_password_instructions(record, token, opts = {})
    super
  end

  protected

  def default_url_options
    {
      host: ENV.fetch("WEB_APP_URL")
    }
  end

  private
end
