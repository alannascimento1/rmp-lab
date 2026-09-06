# rmp-lab

App Rails feito para estudar o **rack-mini-profiler**. Cada página tem um gargalo
plantado de propósito e, ao lado, a mesma página corrigida — a ideia é abrir as duas
com o painel aberto e comparar os números.

## Rodando

```bash
bin/rails db:prepare     # cria o banco (SQLite)
bin/rails db:seed        # 400 usuários, 40k posts, 80k comentários
bin/rails dev:cache      # liga o cache em dev (necessário para o cenário 4)
bin/rails server
```

Abra http://localhost:3000. O badge do profiler aparece no canto superior direito.

## Como ler o painel

- O **badge** mostra o tempo total do request. Clique nele para abrir a árvore.
- Cada linha da árvore é um passo: a action do controller, cada render de view,
  cada step customizado. A indentação mostra o aninhamento.
- O número ao lado de cada linha (`3 sql`) abre o SQL executado ali, com tempo
  individual e backtrace — é onde você descobre **qual linha de código** disparou a query.
- Queries idênticas repetidas aparecem empilhadas na lista de SQL; as respondidas pelo
  query cache do Active Record vêm com a etiqueta `[CACHE]`, e o rodapé mostra o total
  com a contagem de cached — sinal clássico de N+1.

## Os cenários

| # | Rota lenta | Rota corrigida | O que observar |
|---|---|---|---|
| 1 | `/lab/posts/slow` | `/lab/posts/fast` | Dezenas de `SELECT ... WHERE id = ?` duplicados viram 2 queries com `includes`. ~60ms → ~10ms |
| 2 | `/lab/post_rows/slow` | `/lab/post_rows/fast` | Uma linha de render por item na árvore vs. uma única linha. ~27ms → ~14ms |
| 3 | `/lab/lookups/slow` | `/lab/lookups/fast` | Mesma consulta, mesma quantidade; só muda o índice. ~120ms → ~23ms |
| 4 | `/lab/rankings/slow` | `/lab/rankings/fast` | Recarregue a versão com cache: o step continua lá, mas sem SQL embaixo. ~20ms → ~4ms |
| 5 | `/lab/post_counts` | — | `posts.count` (1 query por usuário) vs `counter_cache` (zero queries) |
| 6 | `/lab/quotes` | — | `Rack::MiniProfiler.step` nomeia tempo que não é SQL nem view |
| 6 | `/lab/scores` | — | Request lento sem SQL: caso de usar `?pp=flamegraph` |

## Query strings `?pp=`

Anexe em qualquer URL do app:

| parâmetro | o que faz |
|---|---|
| `?pp=help` | lista todos os comandos |
| `?pp=disable` / `?pp=enable` | liga/desliga o profiler na sessão |
| `?pp=full-backtrace` | inclui frames de gems e do Rails no backtrace |
| `?pp=profile-gc` | contagem de objetos alocados e estatísticas de GC |
| `?pp=analyze-memory` | mapa dos objetos vivos no processo |
| `?pp=env` | o Rack env completo |
| `?pp=flamegraph` | flamegraph (requer a gem `stackprof`) |
| `?pp=profile-memory` | relatório de alocação por linha (requer `memory_profiler`) |

As opções pesadas só funcionam porque
`config.enable_advanced_debugging_tools = true` está ligado — **nunca** faça isso
em produção, elas expõem o estado interno do processo.

### Habilitando o flamegraph

```ruby
# Gemfile, group :development
gem "stackprof"
```

Depois `bundle install` e acesse `/lab/scores?pp=flamegraph`.

## Documentação e amostras (`docs/`)

- [`docs/anatomia-n-mais-um.html`](docs/anatomia-n-mais-um.html) — **artigo**: como ler o painel
  (colunas, backtrace, `[CACHE]`) usando duas medições reais da mesma página, com links de prova
  para as amostras e para o código-fonte da gem.
- [`docs/amostra-profiler-lab_posts_slow-129.6ms.html`](docs/amostra-profiler-lab_posts_slow-129.6ms.html) —
  medição congelada do `/lab/posts/slow`: 129,6 ms, 121 queries (33 cached).
- [`docs/amostra-profiler-lab_posts_fast-21.6ms.html`](docs/amostra-profiler-lab_posts_fast-21.6ms.html) —
  a mesma página corrigida: 21,6 ms, 4 queries.

No GitHub esses links mostram o código-fonte; para ver renderizado, abra os arquivos localmente
depois do clone, ou use o [htmlpreview do artigo](https://htmlpreview.github.io/?https://github.com/alannascimento1/rmp-lab/blob/main/docs/anatomia-n-mais-um.html).
As amostras vêm do botão **share** do próprio profiler, com o CSS embutido para funcionarem offline.

## Arquivos que importam

- `config/initializers/rack_mini_profiler.rb` — configuração comentada opção por opção
- `app/controllers/application_controller.rb` — o helper `profiler_step`, com guard
  para não quebrar em produção onde a gem não existe
- `app/controllers/lab/` — controllers em pares por cenário: `<recurso>/slow` (lento) e `<recurso>/fast` (corrigido), todos só com `index`
- `db/seeds.rb` — geração dos dados via `insert_all`

## Em produção

A gem está no `group :development`. Se um dia você quiser habilitá-la em staging,
use autorização explícita:

```ruby
Rack::MiniProfiler.config.authorization_mode = :allow_authorized
# e, num before_action de admin:
Rack::MiniProfiler.authorize_request
```

Sem isso, qualquer visitante vê os tempos internos e o SQL da sua aplicação.
