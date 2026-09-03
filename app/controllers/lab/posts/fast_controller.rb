module Lab
  module Posts
    # BOM: includes carrega autores e comentarios em 3 queries no total.
    class FastController < SlowController
      def index
        @posts = Post.recent.limit(PAGE_SIZE).includes(:user, :comments)
      end
    end
  end
end
