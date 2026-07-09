Rails.application.routes.draw do
  devise_for :users
  resources :courses
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  get "privacy_policy", to: "static_pages#privacy_policy"
  resources :users, only: [ :index ]

  mount LetterOpenerWeb::Engine, at: "letter_opener" if Rails.env.development?
end
