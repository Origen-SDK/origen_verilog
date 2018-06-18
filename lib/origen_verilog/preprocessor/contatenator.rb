module OrigenVerilog
  module Preprocessor
    # Concatenates all text_block nodes
    class Concatenator < OrigenVerilog::Processor
      def run(node)
        @text_block = nil
        nodes = process_all(node.children)
        nodes << @text_block if @text_block
        node.updated(nil, nodes)
      end

      def on_text_block(node)
        if @text_block
          @text_block = @text_block.updated(:text_block, [@text_block.to_a[0] + node.to_a[0]])
        else
          @text_block = node
        end
        nil
      end
      alias_method :on_comment, :on_text_block

      def on_file(node)
        node = Concatenator.new.run(node)
        if @text_block
          tb = @text_block
          @text_block = nil
          inline [tb, node]
        else
          node
        end
      end

      def handler_missing(node)
        fail "No handler defined for node type: #{node.type}"
      end
    end
  end
end
