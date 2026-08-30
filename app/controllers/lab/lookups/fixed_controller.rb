module Lab
  module Lookups
    # BOM: mesma consulta, mesma quantidade, coluna indexada.
    class FixedController < LookupsController
      def index
        @title = "Busca COM indice"
        @column = "code"
        @posts = lookup(@column)
        render "lab/lookups/index"
      end
    end
  end
end
