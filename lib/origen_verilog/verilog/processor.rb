module OrigenVerilog
  module Verilog
    class Processor < OrigenVerilog::Processor
      def run(ast, env)
        @env = env
        process(ast)
      end

      private

      def env
        @env
      end
    end
  end
end
