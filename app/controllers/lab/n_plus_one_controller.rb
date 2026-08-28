module Lab
  # Cenario 1: N+1
  class NPlusOneController < ApplicationController
    PAGE_SIZE = 30

    # RUIM: 1 query para os posts + 1 por autor + 1 por lista de comentarios.
    # No painel do profiler voce ve dezenas de linhas SQL identicas empilhadas,
    # e o contador de queries do badge explode.
    def show
      @title = "N+1 (ruim)"
      @eager = false
      @posts = Post.recent.limit(PAGE_SIZE)
    end

    # BOM: includes carrega autores e comentarios em 3 queries no total.
    def fixed
      @title = "N+1 resolvido com includes"
      @eager = true
      @posts = Post.recent.limit(PAGE_SIZE).includes(:user, comments: :user)
      render :show
    end
  end
end
