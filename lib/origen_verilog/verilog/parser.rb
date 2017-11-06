require 'treetop'
module OrigenVerilog
  module Verilog
    # Responsible for parsing a Verilog file to an AST
    class Parser
      def self.parse_file(path, options = {})
        parse(File.read(path), options.merge(file: path))
      end

      def self.parse(data, options = {})
        # This will be appended to all nodes if supplied
        @file = options[:file]
        tree = parser.parse(data)

        # If the AST is nil then there was an error during parsing
        # we need to report a simple error message to help the user
        if tree.nil?
          parser.failure_reason =~ /^(Expected .+) (after|at)/m
          @last_error_msg = []
          @last_error_msg << "#{Regexp.last_match(1).gsub("\n", '$NEWLINE')}:"
          @last_error_msg << data.lines.to_a[parser.failure_line - 1]
          @last_error_msg << "#{'~' * (parser.failure_column - 1)}^"
          puts @last_error_msg
        end
        tree
      end

      def self.last_error_msg
        @last_error_msg || []
      end

      def self.parser
        @parser ||= begin
          require "#{Origen.root!}/grammars/verilog"
          GrammarParser.new
        end
      end

      def self.file
        @file
      end
    end
  end
end
