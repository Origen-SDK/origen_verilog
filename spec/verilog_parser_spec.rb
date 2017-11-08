require 'spec_helper'

describe "The Verilog Parser" do

  it "scratch for debug" do
    raw = verilog_parser.parse_file("#{Origen.root}/examples/scratch.v")
    raw.should be
    ast = raw.to_ast
    debugger
  end

  it "it can parse the examples" do
    %w(picorv32 picosoc simpleuart spimemio).each do |file|
      verilog_parser.parse_file("#{Origen.root}/examples/picosoc/#{file}.v").should be
    end
  end
end
