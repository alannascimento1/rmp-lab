# Benchmark simples do cenario N+1: 10 execucoes de cada versao contra o
# servidor local, gerando docs/benchmark-n-mais-um.html com a comparacao.
#
#   bin/rails server  # em outro terminal
#   ruby script/benchmark_n1.rb
require "net/http"

HOST = "localhost"; PORT = 3000; RUNS = 10
ROTAS = { slow: "/lab/posts/slow", fast: "/lab/posts/fast" }

HTTP = Net::HTTP.start(HOST, PORT) # conexao persistente: sem custo de TCP por request

def medir(path)
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  res = HTTP.get(path)
  raise "HTTP #{res.code} em #{path}" unless res.code == "200"
  ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round(1)
end

# aquecimento: primeiras cargas sao frias (templates, pool, file watcher)
ROTAS.each_value { |p| 4.times { medir(p) } }

# execucoes alternadas (ruim, bom, ruim, bom...) para dividirem as mesmas condicoes
tempos = { slow: [], fast: [] }
RUNS.times do
  tempos[:slow] << medir(ROTAS[:slow])
  tempos[:fast] << medir(ROTAS[:fast])
end
media  = ->(a) { (a.sum / a.size).round(1) }
mediana = ->(a) { s = a.sort; (s[(s.size - 1) / 2] + s[s.size / 2]) / 2.0 }

linhas = (0...RUNS).map do |i|
  s, f = tempos[:slow][i], tempos[:fast][i]
  "<tr><td>#{i + 1}</td><td class='num bad'>#{s}</td><td class='num good'>#{f}</td><td class='num'>#{(s / f).round(1)}×</td></tr>"
end.join("\n")

ms, mf = media[tempos[:slow]], media[tempos[:fast]]
vezes = (ms / mf).round(1)

html = <<~HTML
  <!doctype html>
  <html lang="pt-BR">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Benchmark N+1</title>
  <style>
    :root { color-scheme: light; }
    body { margin: 0; background: #f3f5f4; color: #1f2b26;
           font: 16px/1.6 ui-sans-serif, system-ui, sans-serif;
           display: grid; place-items: center; min-height: 100vh; }
    .box { background: #fff; border: 1px solid #d8dedb; border-radius: 10px;
           padding: 28px 36px; max-width: 560px; }
    h1 { font-size: 22px; margin: 0 0 4px; }
    .sub { color: #66716c; font-size: 14px; margin: 0 0 18px; }
    table { border-collapse: collapse; width: 100%; font-variant-numeric: tabular-nums; }
    th, td { padding: 6px 14px; text-align: right; border-bottom: 1px solid #e4e8e6; }
    th { font-size: 12px; text-transform: uppercase; letter-spacing: .05em; color: #66716c; }
    td:first-child, th:first-child { text-align: left; }
    .bad  { color: #c0392b; } .good { color: #1e8449; }
    tfoot td { font-weight: 700; border-top: 2px solid #1f2b26; border-bottom: 0; }
    .veredito { margin: 18px 0 0; font-size: 15px; }
    .veredito b { color: #1e8449; }
    .meta { color: #8a938f; font-size: 12px; margin-top: 10px; }
  </style>
  <div class="box">
    <h1>N+1: ruim × bom</h1>
    <p class="sub">Tempo total da página, em milissegundos — #{RUNS} execuções de cada, após aquecimento.</p>
    <table>
      <thead><tr><th>execução</th><th>ruim (31 queries)</th><th>bom (2 queries)</th><th>razão</th></tr></thead>
      <tbody>
  #{linhas}
      </tbody>
      <tfoot>
        <tr><td>média</td><td class="num bad">#{ms}</td><td class="num good">#{mf}</td><td class="num">#{vezes}×</td></tr>
        <tr><td>mediana</td><td class="num bad">#{mediana[tempos[:slow]].round(1)}</td><td class="num good">#{mediana[tempos[:fast]].round(1)}</td><td></td></tr>
      </tfoot>
    </table>
    <p class="veredito">Mesma página, mesmo dado: a versão com <code>includes</code> ficou <b>#{vezes}× mais rápida</b>.</p>
    <p class="meta">Medido em #{Time.now.strftime("%d/%m/%Y %H:%M")} · Rails em modo development · gerado por script/benchmark_n1.rb</p>
  </div>
  </html>
HTML

File.write(File.expand_path("../docs/benchmark-n-mais-um.html", __dir__), html)
puts "slow: #{tempos[:slow].inspect}"
puts "fast: #{tempos[:fast].inspect}"
puts "media #{ms} vs #{mf} (#{vezes}x) -> docs/benchmark-n-mais-um.html"
