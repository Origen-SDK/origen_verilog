require 'treetop'
module OrigenVerilog
  module Preprocessor
    # Responsible for parsing a Verilog file to an AST
    class Parser < OrigenVerilog::Parser
      def self.node
        OrigenVerilog::Preprocessor::Node
      end

      def self.parser
        @parser ||= begin
          require "#{Origen.root!}/grammars/preprocessor"
          GrammarParser.new
        end
      end
    end
  end
end
