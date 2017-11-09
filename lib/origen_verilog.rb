require 'origen'
require_relative '../config/application.rb'
module OrigenVerilog
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

  autoload :Parser,    'origen_verilog/parser'
  autoload :Node,      'origen_verilog/node'
  autoload :Processor, 'origen_verilog/processor'

  module Verilog
    autoload :Parser, 'origen_verilog/verilog/parser'
    autoload :Node,   'origen_verilog/verilog/node'
  end
  module Preprocessor
    autoload :Parser,    'origen_verilog/preprocessor/parser'
    autoload :Node,      'origen_verilog/preprocessor/node'
    autoload :Processor, 'origen_verilog/preprocessor/processor'
    autoload :Writer,    'origen_verilog/preprocessor/writer'
  end
end
