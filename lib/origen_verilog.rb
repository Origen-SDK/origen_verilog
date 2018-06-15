require 'origen'
require_relative '../config/application.rb'
module OrigenVerilog
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

  autoload :Parser,    'origen_verilog/parser'
  autoload :Node,      'origen_verilog/node'
  autoload :Processor, 'origen_verilog/processor'
  autoload :TopLevel,  'origen_verilog/top_level'

  module Verilog
    autoload :Parser,    'origen_verilog/verilog/parser'
    autoload :Node,      'origen_verilog/verilog/node'
    autoload :Processor, 'origen_verilog/verilog/processor'
    autoload :Writer,    'origen_verilog/verilog/writer'
    autoload :Evaluator, 'origen_verilog/verilog/evaluator'
  end
  module Preprocessor
    autoload :Parser,    'origen_verilog/preprocessor/parser'
    autoload :Node,      'origen_verilog/preprocessor/node'
    autoload :Processor, 'origen_verilog/preprocessor/processor'
    autoload :Writer,    'origen_verilog/preprocessor/writer'
    autoload :Concatenator, 'origen_verilog/preprocessor/contatenator'
    autoload :VerilogParser, 'origen_verilog/preprocessor/verilog_parser'
  end

  # Returns an AST for the given file
  def self.parse_file(file, options = {})
    top_dir = Pathname.new(file).dirname.to_s
    options[:source_dirs] ||= []
    options[:source_dirs] << top_dir unless options[:source_dirs].include?(top_dir)
    # Read in the file to a pre-processor AST (Verilog captured as blocks of text at this point)
    ast = Preprocessor::Parser.parse_file(file, options)
    # Evaluate all compiler directives
    ast = ast.process(options)
    # Now parse as Verilog
    ast = ast.parse_verilog(options.merge(file: file))
  end
end
