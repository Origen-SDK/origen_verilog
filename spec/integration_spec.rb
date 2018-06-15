require 'spec_helper'

describe "the combined pre and verilog parser" do

  it "can parse the scratch example" do
    OrigenVerilog.parse_file("#{Origen.root}/examples/scratch.v").should be
  end
end
