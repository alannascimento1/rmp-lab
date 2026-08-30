module Lab
  module Posts
    # BOM: includes carrega autores e comentarios em 3 queries no total.
    class FixedController < ApplicationController
      def index
        @posts = Post.recent.limit(Lab::PostsController::PAGE_SIZE)
                     .includes(:user, comments: :user)
      end
    end
  end
end
