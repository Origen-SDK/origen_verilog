require 'origen'
require_relative '../config/application.rb'
module OrigenVerilog
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

  # Example of how to explicitly require a file
  # require "origen_verilog/my_file"
  require 'origen_verilog/parser'
  require 'origen_verilog/node'
  require 'origen_verilog/verilog/parser'
  require 'origen_verilog/verilog/node'
  require 'origen_verilog/preprocessor/parser'
  require 'origen_verilog/preprocessor/node'
end
