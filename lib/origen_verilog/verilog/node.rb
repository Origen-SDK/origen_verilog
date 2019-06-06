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

      # Returns an array containing the AST node for all modules in the AST
      def modules
        find_all(:module_declaration)
      end

      # Similar to the modules method, but removes any modules which are instantiated
      # within other modules, therefore leaving only those which could be considered top
      # level
      def top_level_modules
        mods = modules
        modules.reject { |m| mods.any? { |mod| mod.instantiates?(m) } }
      end

      # Returns true if the node instantiates the given module node or module name
      def instantiates?(module_or_name)
        name = module_or_name.respond_to?(:to_a) ? module_or_name.to_a[0] : module_or_name
        instantiations = find_all(:module_instantiation)
        if instantiations.empty?
          false
        else
          instantiations.any? { |i| i.to_a[0].to_s == name.to_s }
        end
      end

      # Returns the AST node for the module with the given name
      def module(name)
        find_all(:module_declaration).find { |n| n.to_a[0].to_s == name.to_s }
      end

      # Returns the name of the node, will raise an error if called on a node type for
      # which the name extraction is not yet implemented
      def name
        if type == :module_declaration
          to_a[0]
        else
          fail "Don't know how to extract the name from a #{type} node yet!"
        end
      end

      # Returns an array containing all input, output and inout AST nodes.
      # Supply analog: true in the options to return only those pins defined as a
      # real/wreal type and digital: true to return only the pins without a real/wreal
      # type.
      def pins(options = {})
        pins = find_all(:input_declaration, :output_declaration, :inout_declaration)
        if options[:analog] || options[:digital]
          wreals = self.wreals.map { |n| n.to_a.last }
          subset = []
          pins.each do |pin|
            if pin.find(:real) || wreals.include?(pin.to_a.last)
              subset << pin if options[:analog]
            else
              subset << pin if options[:digital]
            end
          end
          subset
        else
          pins
        end
      end

      # Returns an array containing all wire real/wreal declaration AST nodes, which have
      # been declared as part of a module definition, returning something like this:
      #       [
      #         s(:net_declaration, "real", "vdd")),
      #         s(:net_declaration, "real", "vddf")),
      #       ]
      def wreals
        find_all(:non_port_module_item)
          .map { |item| item.find(:net_declaration) }
          .select { |net| net.find(:real) }
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
        Origen.target.temporary = -> { TopLevel.new(ast: self) }
        Origen.load_target
      end
    end
  end
end
