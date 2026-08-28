class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  private

  # Envolve um trecho de codigo num "step" customizado do profiler.
  # No painel ele aparece como uma linha propria, aninhada sob a action —
  # e' assim que voce mede pedacos que nao sao SQL nem render de view
  # (chamada HTTP, parse de arquivo, calculo pesado).
  #
  # O guard mantem o codigo seguro em producao, onde a gem nao existe.
  def profiler_step(name)
    return yield unless defined?(Rack::MiniProfiler)

    Rack::MiniProfiler.step(name) { yield }
  end
  helper_method :profiler_step
end
