require 'treetop'
require 'origen_verilog/node'
module OrigenVerilog
  class Parser
    def self.parse_file(path, options = {})
      parse(File.read(path), options.merge(file: path))
    end

    def self.parse(data, options = {})
      # This will be appended to all nodes if supplied
      @file = options[:file]
      Treetop.origen_verilog_parser = self
      tree = parser.parse(data)

      # If the AST is nil then there was an error during parsing
      # we need to report a simple error message to help the user
      if tree.nil? && !options[:quiet]
        parser.failure_reason =~ /^(Expected .+) (after|at)/m
        @last_error_msg = []
        @last_error_msg << "#{Regexp.last_match(1).gsub("\n", '$NEWLINE')}:" if Regexp.last_match(1)
        if parser.failure_line >= data.lines.to_a.size
          @last_error_msg << 'EOF'
        else
          @last_error_msg << data.lines.to_a[parser.failure_line - 1].gsub("\t", ' ')
        end
        @last_error_msg << "#{'~' * (parser.failure_column - 1)}^"
        puts "Failed parsing Verilog file: #{file}"
        puts @last_error_msg
      end
      if tree
        tree.to_ast
      end
    end

    def self.last_error_msg
      @last_error_msg || []
    end

    def self.file
      @file
    end
  end
end
