Rails.application.routes.draw do
  root "lab/home#index"

  # Cada cenario pareado e' um namespace com dois controllers REST:
  # `slow` (a versao lenta) e `fast` (a corrigida), ambos so' com `index`.
  namespace :lab do
    namespace :posts do      # 1. N+1
      resources :slow, only: :index
      resources :fast, only: :index
    end
    namespace :post_rows do  # 2. render de view
      resources :slow, only: :index
      resources :fast, only: :index
    end
    namespace :lookups do    # 3. indice
      resources :slow, only: :index
      resources :fast, only: :index
    end
    namespace :rankings do   # 4. cache
      resources :slow, only: :index
      resources :fast, only: :index
    end

    resources :post_counts, only: :index   # 5. count x counter_cache
    resources :quotes,      only: :index   # 6a. API externa
    resources :scores,      only: :index   # 6b. CPU em Ruby
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
