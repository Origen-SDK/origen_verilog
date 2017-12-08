module OrigenVerilog
  module Verilog
    class Evaluator < OrigenVerilog::Processor
      def run(ast)
        ast.updated(nil, process_all(ast.children))
      end

      def on_decimal_number(node)
        process(node.value)
      end

      def on_constant_primary(node)
        process(node.value)
      end
    end
  end
end
