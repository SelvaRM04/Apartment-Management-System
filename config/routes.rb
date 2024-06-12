Rails.application.routes.draw do
  resources :admins
  resources :securities
  resources :messages
  resources :owners
  resources :tenants
  resources :houses
  resources :blocks
  resources :apartments
  resources :sessions, only: [ :new]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root "apartments#main_page"

  get "/signup/owner", to: "owners#new"
  get "/:desig/login", to: "sessions#new", as: "login"
  post "/login/:desig", to: "sessions#create", as: "login_create"
  delete "logout", to: "sessions#destroy", as: "logout"
  post "/add_house", to: "houses#create", as: "add_house"

  post "/approve", to: "messages#approve", as: "approve"

end
