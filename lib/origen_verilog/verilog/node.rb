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

      # Converts a module node to an Origen top-level model.
      #
      # This will re-load the Origen target with the resultant model instantiated
      # as the global dut object.
      def to_top_level
        unless type == :module_declaration
          fail 'Currently only modules support the to_model method'
        end
        Origen.target.temporary = -> { TopLevel.new(ast: evaluate) }
        Origen.load_target
      end
    end
  end
end
