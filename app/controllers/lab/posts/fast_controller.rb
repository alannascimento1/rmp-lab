module Lab
  module Posts
    # BOM: includes carrega os 30 autores em 1 query extra: 2 no total.
    class FastController < SlowController
      def index
        @posts = Post.recent.limit(PAGE_SIZE).includes(:user)
      end
    end
  end
end
