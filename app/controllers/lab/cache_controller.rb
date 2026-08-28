module Lab
  # Cenario 4: cache de fragmento
  class CacheController < ApplicationController
    # RUIM: agrega no banco a cada request.
    def show
      @title = "Ranking sem cache"
      @cached = false
      @rows = profiler_step("agregacao no banco") { top_authors }
    end

    # BOM: mesmo resultado, memorizado em cache. O primeiro acesso e' lento,
    # os seguintes viram uma leitura de cache — compare os dois no profiler.
    def fixed
      @title = "Ranking com cache"
      @cached = true
      @rows = profiler_step("Rails.cache.fetch(top_authors)") do
        Rails.cache.fetch("lab/top_authors", expires_in: 5.minutes) { top_authors }
      end
      render :show
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
