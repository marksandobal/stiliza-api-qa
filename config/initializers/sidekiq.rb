# rubocop:disable Layout/ElseAlignment, Layout/EndAlignment

sidekiq_config =  if Rails.env.production?
                    {
                      url: ENV["REDIS_TLS_URL"],
                      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
                    }
                  else
                    params = {
                      db: 1,
                      host: ENV["REDIS_HOST"],
                      port: ENV["REDIS_PORT"]
                    }

                    if ENV["REDIS_PASSWORD"]
                      params[:password] = ENV["REDIS_PASSWORD"]
                    end
                    params
                  end
# rubocop:enable Layout/ElseAlignment, Layout/EndAlignment

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
