Rails.application.routes.draw do
  resources :enrollments,  expect: %i[new create] do
    get :my_students, on: :collection
  end
  resources :courses do
    get :purchased, on: :collection
    get :pending_review, on: :collection
    get :created, on: :collection
    resources :lessons
    resources :enrollments, only: %i[ new create ]
  end
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  get "activity", to: "home#activity"
  get "privacy_policy", to: "static_pages#privacy_policy"

  devise_for :users, controllers: {
    confirmations: "users/confirmations"
  }

  resources :users, only: [ :index, :show, :edit, :update ]

  get "analytics", to: "home#analytics"

  get "charts/users_per_day", to: "charts#users_per_day"
  get "charts/enrollments_per_day", to: "charts#enrollments_per_day"
  get "charts/course_popularity", to: "charts#course_popularity"



  mount LetterOpenerWeb::Engine, at: "letter_opener" if Rails.env.development?
end
