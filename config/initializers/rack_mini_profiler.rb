# ---------------------------------------------------------------------------
# rack-mini-profiler — configuracao comentada
#
# A gem esta no group :development, entao este arquivo so' tem efeito em dev.
# O Railtie da gem injeta o middleware sozinho; aqui so' ajustamos o
# comportamento. Toda opcao vive em Rack::MiniProfiler.config.
# ---------------------------------------------------------------------------
return unless defined?(Rack::MiniProfiler)

Rack::MiniProfiler.config.tap do |config|
  # Onde o badge (aquele retangulo com os ms) aparece na pagina.
  # Opcoes: "left", "right", "top-left", "top-right", "bottom-left", "bottom-right"
  config.position = "top-right"

  # false = o painel ja' vem aberto. true = so' o badge, clique para expandir.
  config.start_hidden = false

  # Libera as ferramentas pesadas via query string:
  #   ?pp=profile-gc        -> estatisticas de alocacao de objetos
  #   ?pp=analyze-memory    -> mapa de memoria do processo
  #   ?pp=flamegraph        -> exige a gem stackprof
  #   ?pp=profile-memory    -> exige a gem memory_profiler
  # NUNCA habilite isso em producao: expoe estado interno do processo.
  config.enable_advanced_debugging_tools = true

  # Requests que nao valem a pena instrumentar (assets, healthcheck).
  config.skip_paths = [ "/assets", "/up", "/favicon.ico" ]

  # Qualquer query/step acima deste limite ganha backtrace clicavel no painel.
  # Baixe para 0 se quiser backtrace de tudo (fica verboso).
  config.backtrace_threshold_ms = 0

  # Esconde as queries internas do Rails (descoberta de colunas/schema).
  # E' o default; com false elas aparecem no painel — util para estudar o boot
  # de uma request, mas poluem os cenarios do lab.
  config.skip_schema_queries = true

  # Onde os snapshots dos requests ficam. MemoryStore some quando o servidor
  # reinicia — perfeito para dev. Em ambientes com varios processos use
  # Rack::MiniProfiler::RedisStore.new(connection: Redis.new).
  config.storage = Rack::MiniProfiler::MemoryStore

  # Guarda os N ultimos requests para o painel "snapshots" (?pp=snapshots).
  config.snapshots_transport_destination_url = nil

  # Autorizacao: em dev todo mundo ve'. Em staging/producao o padrao seguro e'
  # exigir autorizacao explicita por sessao:
  #
  #   config.authorization_mode = :allow_authorized
  #
  # e, num before_action de admin:
  #
  #   Rack::MiniProfiler.authorize_request
end
