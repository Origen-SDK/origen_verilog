module OrigenVerilog
  module Preprocessor
    class Node < OrigenVerilog::Node
      def process(file = nil, env = {})
        file, env = nil, file if file.is_a?(Hash)
        ast = Processor.new.run(self, env)
        if file
          Writer.new.run(file, ast)
        else
          ast
        end
      end

      def to_s
        Writer.new.to_s(self)
      end
    end
  end
end
