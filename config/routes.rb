Rails.application.routes.draw do
  # routes availables only dev and staging/ not production
  unless Rails.env.production?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end

  devise_for :users,
    defaults: { format: :json },
    controllers: {
      registrations: "users/registrations",
      passwords: "users/passwords",
      sessions: "users/sessions"
    },
    path: "",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup",
      password: "password"
    }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Verification account routes
  namespace :users do
    post "verification" => "verification#verify"
    post "resend_verification", to: "verification#resend"
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
