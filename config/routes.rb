Rails.application.routes.draw do
  resources :courses do
    resources :lessons
  end
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  get "activity", to: "home#activity"
  get "privacy_policy", to: "static_pages#privacy_policy"

  devise_for :users, controllers: {
    confirmations: "users/confirmations"
  }

  resources :users, only: [ :index, :show, :edit, :update ]

  mount LetterOpenerWeb::Engine, at: "letter_opener" if Rails.env.development?
end
