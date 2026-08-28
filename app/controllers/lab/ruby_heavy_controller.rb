module Lab
  # Cenario 6b: CPU em Ruby puro — quase nada de SQL, mas o request demora.
  # Este e' o caso em que voce recorre a ?pp=flamegraph.
  class RubyHeavyController < ApplicationController
    def show
      @posts = Post.limit(60).to_a
      @scores = profiler_step("calculo em Ruby (60x expensive_score)") do
        @posts.map(&:expensive_score)
      end
    end
  end
end
