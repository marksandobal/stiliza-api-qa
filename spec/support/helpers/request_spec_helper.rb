require 'devise/jwt'
require 'devise/jwt/test_helpers'

module RequestSpecHelper
  def auth_headers(user, company_id)
    auth_headers = Devise::JWT::TestHelpers.auth_headers({}, user)

    auth_headers.merge({
      'Accept' => 'application/vnd.stiliza-api.v1+json',
      'Content-Type' => 'application/json',
      'Current-Company-Id' => company_id.to_s
    })
  end
end
