class LabController < ApplicationController
  PAGE_SIZE = 30

  def index
    @stats = {
      users:    User.count,
      posts:    Post.count,
      comments: Comment.count,
      tags:     Tag.count
    }
  end

  # ---------------------------------------------------------------------
  # 1. N+1
  # ---------------------------------------------------------------------

  # RUIM: 1 query para os posts + 1 por autor + 1 por lista de comentarios.
  # No painel do profiler voce ve dezenas de linhas SQL identicas empilhadas,
  # e o contador de queries do badge explode.
  def n_plus_one
    @posts = Post.recent.limit(PAGE_SIZE)
    render :posts_list, locals: { title: "N+1 (ruim)", eager: false }
  end

  # BOM: includes carrega autores e comentarios em 3 queries no total.
  def n_plus_one_fixed
    @posts = Post.recent.limit(PAGE_SIZE).includes(:user, comments: :user)
    render :posts_list, locals: { title: "N+1 resolvido com includes", eager: true }
  end

  # ---------------------------------------------------------------------
  # 2. Render de view
  # ---------------------------------------------------------------------

  # RUIM: render dentro de loop -> o Rails resolve o template a cada iteracao.
  # O profiler mostra uma linha "Rendering: lab/_post_row" por item.
  def slow_view
    @posts = Post.recent.limit(200).includes(:user)
    render :slow_view
  end

  # BOM: render de collection -> o template e' resolvido uma vez so'.
  def slow_view_fixed
    @posts = Post.recent.limit(200).includes(:user)
    render :slow_view_fixed
  end

  # ---------------------------------------------------------------------
  # 3. Indice
  # ---------------------------------------------------------------------

  LOOKUPS = 40

  # RUIM: legacy_code nao tem indice -> cada busca varre a tabela inteira.
  def missing_index
    codes = lookup_codes
    @posts = profiler_step("#{LOOKUPS} SELECTs sem indice (legacy_code)") do
      codes.flat_map { |code| Post.where(legacy_code: code).to_a }
    end
    render :index_compare, locals: { title: "Busca SEM indice", column: "legacy_code" }
  end

  # BOM: mesma consulta, mesma quantidade, coluna indexada.
  def with_index
    codes = lookup_codes
    @posts = profiler_step("#{LOOKUPS} SELECTs com indice (code)") do
      codes.flat_map { |code| Post.where(code: code).to_a }
    end
    render :index_compare, locals: { title: "Busca COM indice", column: "code" }
  end

  # ---------------------------------------------------------------------
  # 4. Cache de fragmento
  # ---------------------------------------------------------------------

  # RUIM: agrega no banco a cada request.
  def uncached
    @rows = profiler_step("agregacao no banco") { top_authors }
    render :ranking, locals: { title: "Ranking sem cache", cached: false }
  end

  # BOM: mesmo resultado, memorizado em cache. O primeiro acesso e' lento,
  # os seguintes viram uma leitura de cache — compare os dois no profiler.
  def cached
    @rows = profiler_step("Rails.cache.fetch(top_authors)") do
      Rails.cache.fetch("lab/top_authors", expires_in: 5.minutes) { top_authors }
    end
    render :ranking, locals: { title: "Ranking com cache", cached: true }
  end

  # ---------------------------------------------------------------------
  # 5. count x size x counter_cache
  # ---------------------------------------------------------------------
  def counting
    @users = User.limit(25).to_a

    @with_count = profiler_step("user.posts.count (1 query por usuario)") do
      @users.map(&:slow_post_count).sum
    end

    @with_counter_cache = profiler_step("user.posts_count (zero queries)") do
      @users.map(&:cached_post_count).sum
    end
  end

  # ---------------------------------------------------------------------
  # 6. Tempo que nao e' SQL nem view
  # ---------------------------------------------------------------------

  # Latencia de rede simulada. Sem o step customizado esse tempo apareceria
  # como um buraco silencioso no request.
  def external_api
    @payload = profiler_step("GET https://api-ficticia/cotacoes (sleep 300ms)") do
      sleep 0.3
      { rate: 5.42, fetched_at: Time.current }
    end

    @second = profiler_step("POST https://api-ficticia/eventos (sleep 120ms)") do
      sleep 0.12
      { ok: true }
    end
  end

  # CPU em Ruby puro: quase nada de SQL, mas o request demora.
  # Este e' o caso em que voce recorre a ?pp=flamegraph.
  def ruby_heavy
    @posts = Post.limit(60).to_a
    @scores = profiler_step("calculo em Ruby (60x expensive_score)") do
      @posts.map(&:expensive_score)
    end
  end

  private

  # Codigos espalhados pela tabela, para o banco nao conseguir se apoiar
  # em uma unica pagina ja' aquecida em memoria.
  def lookup_codes
    total = Post.count
    step = [ total / LOOKUPS, 1 ].max
    Array.new(LOOKUPS) { |i| "PST-%06d" % [ (i * step) + 1 ] }
  end

  def top_authors
    User.joins(posts: :comments)
        .group("users.id", "users.name")
        .order(Arel.sql("COUNT(comments.id) DESC"))
        .limit(10)
        .pluck("users.name", Arel.sql("COUNT(comments.id)"))
  end
end
