module Lab
  # Cenario 4: cache de fragmento
  class RankingsController < ApplicationController
    # RUIM: agrega no banco a cada request.
    def index
      @rows = profiler_step("agregacao no banco") { top_authors }
    end

    private

    def top_authors
      User.joins(posts: :comments)
          .group("users.id", "users.name")
          .order(Arel.sql("COUNT(comments.id) DESC"))
          .limit(10)
          .pluck("users.name", Arel.sql("COUNT(comments.id)"))
    end
  end
end
