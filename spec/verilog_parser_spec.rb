require 'spec_helper'

describe "The Verilog Parser" do

  it "is alive" do
    #verilog_parser.parse_file("#{Origen.root}/examples/picosoc/picosoc.v")
    raw = verilog_parser.parse_file("#{Origen.root}/examples/scratch.v")
    raw.should be
    ast = raw.to_ast
    debugger
  end
end
