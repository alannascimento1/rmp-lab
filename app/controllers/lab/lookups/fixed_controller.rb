module Lab
  module Lookups
    # BOM: mesma consulta, mesma quantidade, coluna indexada.
    class FixedController < LookupsController
      def index
        @posts = lookup("code")
      end
    end
  end
end
