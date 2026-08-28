module Lab
  # Cenario 5: count x size x counter_cache
  class PostCountsController < ApplicationController
    def index
      @users = User.limit(25).to_a

      @with_count = profiler_step("user.posts.count (1 query por usuario)") do
        @users.map(&:slow_post_count).sum
      end

      @with_counter_cache = profiler_step("user.posts_count (zero queries)") do
        @users.map(&:cached_post_count).sum
      end
    end
  end
end
