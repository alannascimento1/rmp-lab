Rails.application.routes.draw do
  root "lab/home#index"

  # Cada cenario e' um resource: `show` e' a versao lenta, `fixed` a corrigida.
  # Abra as duas com o painel do profiler aberto e compare os numeros.
  namespace :lab do
    resource :n_plus_one,     only: :show, controller: :n_plus_one     do get :fixed end
    resource :view_rendering, only: :show, controller: :view_rendering do get :fixed end
    resource :indexing,       only: :show, controller: :indexing       do get :fixed end
    resource :cache,          only: :show, controller: :cache          do get :fixed end

    resource :counting,     only: :show, controller: :counting
    resource :external_api, only: :show, controller: :external_api
    resource :ruby_heavy,   only: :show, controller: :ruby_heavy
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
