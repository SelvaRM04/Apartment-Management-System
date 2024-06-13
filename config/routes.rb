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
  get "/login/:desig", to: "sessions#new", as: "login"
  post "/login/:desig", to: "sessions#create", as: "login_create"
  delete "logout", to: "sessions#destroy", as: "logout"
  post "/add_house", to: "houses#create", as: "add_house"
  post "/add", to: "admins#add", as: "add"
  post "/approve", to: "messages#approve", as: "approve"
  get "/add", to: "admins#add_security", as: "add_security"

  # /home - Routes
  get 'home', to: 'owners#show', constraints: RoleRouteConstraint.new { |desig| desig == "Owner" }
  get 'home', to: 'securities#show', constraints: RoleRouteConstraint.new { |desig| desig == "Security" }  
  get 'home', to: 'houses#show', constraints: RoleRouteConstraint.new { |desig| desig == "Tenant" } 
  get 'home', to: 'admins#show', constraints: RoleRouteConstraint.new { |desig| desig == "Admin" }
  get 'home', to: 'apartments#main_page'

  # / - Routes
  # get '/', to: 'owners#show', constraints: RoleRouteConstraint.new { |desig| desig == "Owner" }
  # get '/', to: 'securities#show', constraints: RoleRouteConstraint.new { |desig| desig == "Security" }  
  # get '/', to: 'houses#show', constraints: RoleRouteConstraint.new { |desig| desig == "Tenant" } 
  # get '/', to: 'admins#show', constraints: RoleRouteConstraint.new { |desig| desig == "Admin" }

  # /signup - Routes
  get 'signup/owner', to: 'owners#new'
  get 'signup/tenant', to: 'tenants#new'
  get 'signup/security', to: 'securities#new'
  get 'signup/admin', to: 'admins#new'
 
  
  # /home - Routes
  get 'edit', to: 'owners#edit', constraints: RoleRouteConstraint.new { |desig| desig == "Owner" }
  get 'edit', to: 'securities#edit', constraints: RoleRouteConstraint.new { |desig| desig == "Security" }  
  get 'edit', to: 'tenants#edit', constraints: RoleRouteConstraint.new { |desig| desig == "Tenant" } 
  get 'edit', to: 'admins#edit', constraints: RoleRouteConstraint.new { |desig| desig == "Admin" } 
  get 'edit', to: 'apartments#main_page'
end


