Rails.application.routes.draw do
  root "lab/home#index"

  # Cada cenario e' um recurso: `index` e' a versao lenta, `fixed` a corrigida.
  # Abra as duas com o painel do profiler aberto e compare os numeros.
  namespace :lab do
    resources :posts,       only: :index do get :fixed, on: :collection end  # 1. N+1
    resources :post_rows,   only: :index do get :fixed, on: :collection end  # 2. render de view
    resources :lookups,     only: :index do get :fixed, on: :collection end  # 3. indice
    resources :rankings,    only: :index do get :fixed, on: :collection end  # 4. cache
    resources :post_counts, only: :index   # 5. count x counter_cache
    resources :quotes,      only: :index   # 6a. API externa
    resources :scores,      only: :index   # 6b. CPU em Ruby
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
