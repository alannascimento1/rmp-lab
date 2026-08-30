module Lab
  # Cenario 1: N+1
  class PostsController < ApplicationController
    PAGE_SIZE = 30

    # RUIM: 1 query para os posts + 1 por autor + 1 por lista de comentarios.
    # No painel do profiler voce ve dezenas de linhas SQL identicas empilhadas,
    # e o contador de queries do badge explode.
    def index
      @posts = Post.recent.limit(PAGE_SIZE)
    end
  end
end
