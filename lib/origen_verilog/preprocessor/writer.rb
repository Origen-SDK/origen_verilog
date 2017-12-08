module OrigenVerilog
  module Preprocessor
    class Writer < OrigenVerilog::Processor
      # Write the given ast to the given file
      def run(file, ast)
        File.open(file, 'w') do |file|
          @file = file
          process(ast)
        end
      end

      # Write the given ast to a string and returns it
      def to_s(ast)
        @file = ''
        process(ast)
        @file
      end

      def on_text_block(node)
        if f.is_a?(String)
          f << node.to_a[0]
        else
          f.write(node.to_a[0])
        end
      end
      alias_method :on_comment, :on_text_block

      private

      def f
        @file
      end
    end
  end
end
