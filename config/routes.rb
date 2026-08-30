Rails.application.routes.draw do
  root "lab/home#index"

  # Cada cenario e' um recurso com apenas `index`. A versao corrigida e' um
  # sub-recurso proprio (`<recurso>/fixed`), tambem so' com `index` —
  # nada de action customizada.
  namespace :lab do
    resources :posts,     only: :index   # 1. N+1 (ruim)
    resources :post_rows, only: :index   # 2. render de view (ruim)
    resources :lookups,   only: :index   # 3. indice (ruim)
    resources :rankings,  only: :index   # 4. cache (ruim)

    namespace :posts     do resources :fixed, only: :index end
    namespace :post_rows do resources :fixed, only: :index end
    namespace :lookups   do resources :fixed, only: :index end
    namespace :rankings  do resources :fixed, only: :index end

    resources :post_counts, only: :index   # 5. count x counter_cache
    resources :quotes,      only: :index   # 6a. API externa
    resources :scores,      only: :index   # 6b. CPU em Ruby
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
