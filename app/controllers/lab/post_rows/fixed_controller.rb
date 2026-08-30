module Lab
  module PostRows
    # BOM: render de collection -> o template e' resolvido uma vez so'.
    class FixedController < ApplicationController
      def index
        @posts = Post.recent.limit(Lab::PostRowsController::PAGE_SIZE).includes(:user)
      end
    end
  end
end
