module OrigenVerilog
  module Preprocessor
    # Invokes the Verilog parser on all text_block nodes, transforming the
    # given pre-processor output AST into a Verilog AST
    class VerilogParser < OrigenVerilog::Processor
      def run(node, options = {})
        @nodes = []
        @file = options[:file]
        @options = options
        process_all(node.children)
        Verilog::Node.new(:verilog_source, @nodes, file: @file)
      end

      def on_text_block(node)
        node = Verilog::Parser.parse(node.to_a[0], @options.merge(file: @file))
        @nodes += node.children
        nil
      end

      def on_file(node)
        file, *nodes = *node
        node = VerilogParser.new.run(node.updated(nil, nodes), @options.merge(file: file))
        @nodes += node.children
        nil
      end

      def handler_missing(node)
        fail "No handler defined for node type: #{node.type}"
      end
    end
  end
end
