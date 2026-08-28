module Lab
  # Cenario 3: indice
  class IndexingController < ApplicationController
    LOOKUPS = 40

    # RUIM: legacy_code nao tem indice -> cada busca varre a tabela inteira.
    def show
      @title = "Busca SEM indice"
      @column = "legacy_code"
      @posts = lookup(@column)
    end

    # BOM: mesma consulta, mesma quantidade, coluna indexada.
    def fixed
      @title = "Busca COM indice"
      @column = "code"
      @posts = lookup(@column)
      render :show
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
