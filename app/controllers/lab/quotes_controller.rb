module Lab
  # Cenario 6a: tempo que nao e' SQL nem view.
  # Latencia de rede simulada. Sem o step customizado esse tempo apareceria
  # como um buraco silencioso no request.
  class QuotesController < ApplicationController
    def index
      @payload = profiler_step("GET https://api-ficticia/cotacoes (sleep 300ms)") do
        sleep 0.3
        { rate: 5.42, fetched_at: Time.current }
      end

      @second = profiler_step("POST https://api-ficticia/eventos (sleep 120ms)") do
        sleep 0.12
        { ok: true }
      end
    end
  end
end
