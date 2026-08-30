module Lab
  # Cenario 2: render de view
  class PostRowsController < ApplicationController
    PAGE_SIZE = 200

    # RUIM: render dentro de loop -> o Rails resolve o template a cada iteracao.
    # O profiler mostra uma linha "Rendering: lab/shared/_post_row" por item.
    def index
      @posts = Post.recent.limit(PAGE_SIZE).includes(:user)
    end
  end
end
