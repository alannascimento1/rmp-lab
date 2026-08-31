module Lab
  module Rankings
    # BOM: mesmo resultado, memorizado em cache. O primeiro acesso e' lento,
    # os seguintes viram uma leitura de cache — compare os dois no profiler.
    class FastController < SlowController
      def index
        @rows = profiler_step("Rails.cache.fetch(top_authors)") do
          Rails.cache.fetch("lab/top_authors", expires_in: 5.minutes) { top_authors }
        end
      end
    end
  end
end
