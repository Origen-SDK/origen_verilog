module OrigenVerilog
  module Verilog
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

      # Returns an array containing the names of all top-level modules in
      # the AST
      def module_names
        find_all(:module_declaration).map { |n| n.to_a[0] }
      end

      # Returns an array containing the AST node for all modules in the AST
      def modules
        find_all(:module_declaration)
      end

      # Returns the AST node for the module with the given name
      def module(name)
        find_all(:module_declaration).find { |n| n.to_a[0].to_s == name.to_s }
      end

      # Returns an array containing all input, output and inout AST nodes
      def pins
        find_all(:input_declaration, :output_declaration, :inout_declaration)
      end

      # Evaluates all functions and turns numbers into Ruby literals
      def evaluate
        Evaluator.new.run(self)
      end

      def to_model
        unless type == :module_declaration
          fail 'Currently only modules support the to_model method'
        end
        Model.new(ast: evaluate)
      end
    end
  end
end
