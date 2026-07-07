Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  get "privacy_policy", to: "static_pages#privacy_policy"
end
