Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :documents, only: [:show] do
        get :envelope, to: :envelope
      end
      resources :events, only: [:create, :show]
    end
  end
end
