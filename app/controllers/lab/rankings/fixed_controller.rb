module Lab
  module Rankings
    # BOM: mesmo resultado, memorizado em cache. O primeiro acesso e' lento,
    # os seguintes viram uma leitura de cache — compare os dois no profiler.
    class FixedController < RankingsController
      def index
        @title = "Ranking com cache"
        @cached = true
        @rows = profiler_step("Rails.cache.fetch(top_authors)") do
          Rails.cache.fetch("lab/top_authors", expires_in: 5.minutes) { top_authors }
        end
        render "lab/rankings/index"
      end
    end
  end
end
