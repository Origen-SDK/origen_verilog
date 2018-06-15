module OrigenVerilog
  module Verilog
    class Evaluator < OrigenVerilog::Processor
      def run(ast)
        ast.updated(nil, process_all(ast.children))
      end

      def on_constant_expression(node)
        nodes = process_all(node.children)
        nodes = nodes.map { |n| n.is_a?(Node) ? process(n.value) : n }
        # Ruby should be close enough to Verilog to just eval the expression for most cases
        eval(nodes.join(' '))
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
