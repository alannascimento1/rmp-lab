module Lab
  module Posts
    # BOM: includes carrega autores e comentarios em 3 queries no total.
    class FixedController < ApplicationController
      def index
        @title = "N+1 resolvido com includes"
        @eager = true
        @posts = Post.recent.limit(Lab::PostsController::PAGE_SIZE)
                     .includes(:user, comments: :user)
        render "lab/posts/index"
      end
    end
  end
end
