require 'spec_helper'

describe "the combined pre and verilog parser" do

  it "can parse the scratch example" do
    ast = nil

    begin
      ast = OrigenVerilog.parse_file("#{Origen.root}/examples/scratch.v").should be
    rescue SystemExit
    end

    ast.should be
  end
end
