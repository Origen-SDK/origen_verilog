module OrigenVerilog
  module Preprocessor
    class Writer < OrigenVerilog::Processor
      def run(file, ast)
        File.open(file, 'w') do |file|
          @file = file
          process(ast)
        end
      end

      def on_text_block(node)
        f.write(node.to_a[0])
      end
      alias_method :on_comment, :on_text_block

      private

      def f
        @file
      end
    end
  end
end
