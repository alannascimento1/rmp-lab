module Lab
  module Posts
    # Cenario 1: N+1
    # RUIM: 1 query para os posts + 1 por autor + 1 por lista de comentarios.
    # No painel do profiler voce ve dezenas de linhas SQL identicas empilhadas,
    # e o contador de queries do badge explode.
    class SlowController < ApplicationController
      PAGE_SIZE = 30

      def index
        @posts = Post.recent.limit(PAGE_SIZE)
      end
    end
  end
end
