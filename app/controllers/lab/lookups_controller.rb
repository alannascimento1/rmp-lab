module Lab
  # Cenario 3: indice
  class LookupsController < ApplicationController
    LOOKUPS = 40

    # RUIM: legacy_code nao tem indice -> cada busca varre a tabela inteira.
    def index
      @posts = lookup("legacy_code")
    end

    private

    def lookup(column)
      codes = lookup_codes
      profiler_step("#{LOOKUPS} SELECTs em #{column}") do
        codes.flat_map { |code| Post.where(column => code).to_a }
      end
    end

    # Codigos espalhados pela tabela, para o banco nao conseguir se apoiar
    # em uma unica pagina ja' aquecida em memoria.
    def lookup_codes
      total = Post.count
      step = [ total / LOOKUPS, 1 ].max
      Array.new(LOOKUPS) { |i| "PST-%06d" % [ (i * step) + 1 ] }
    end
  end
end
