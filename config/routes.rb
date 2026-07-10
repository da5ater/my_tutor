Rails.application.routes.draw do
  resources :courses
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  get "privacy_policy", to: "static_pages#privacy_policy"
  resources :users, only: [ :index ]

  devise_for :users, controllers: {
    confirmations: "users/confirmations"
  }

  mount LetterOpenerWeb::Engine, at: "letter_opener" if Rails.env.development?
end
