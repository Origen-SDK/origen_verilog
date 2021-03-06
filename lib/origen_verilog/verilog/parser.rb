require 'treetop'
module OrigenVerilog
  module Verilog
    # Responsible for parsing a Verilog file to an AST
    class Parser < OrigenVerilog::Parser
      def self.node
        OrigenVerilog::Verilog::Node
      end

      def self.parser
        @parser ||= begin
          require "#{Origen.root!}/grammars/verilog"
          GrammarParser.new
        end
      end
    end
  end
end
