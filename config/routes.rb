Rails.application.routes.draw do
  root "lab#index"

  # Cada cenario vem em par: a versao lenta e a versao corrigida.
  # Abra as duas com o painel do profiler aberto e compare os numeros.
  get "n_plus_one",       to: "lab#n_plus_one"
  get "n_plus_one_fixed", to: "lab#n_plus_one_fixed"

  get "slow_view",        to: "lab#slow_view"
  get "slow_view_fixed",  to: "lab#slow_view_fixed"

  get "missing_index",    to: "lab#missing_index"
  get "with_index",       to: "lab#with_index"

  get "uncached",         to: "lab#uncached"
  get "cached",           to: "lab#cached"

  get "counting",         to: "lab#counting"

  get "external_api",     to: "lab#external_api"
  get "ruby_heavy",       to: "lab#ruby_heavy"

  get "up", to: "rails/health#show", as: :rails_health_check
end
