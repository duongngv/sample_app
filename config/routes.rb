Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    concern :paginatable do
      get "(page/:page)", action: :index, on: :collection, as: ""
    end
    resources :users, concerns: :paginatable do
      member do
        get :following, action: :following, controller: "following"
        get :followers, action: :followers, controller: "followers"
      end
    end
    resources :microposts, only: [:create, :destroy]
    resources :relationships, only: [:create, :destroy]
    resources :account_activations, only: :edit
  end
end
