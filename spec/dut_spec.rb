require 'spec_helper'

describe 'Parsing a Verilog file into an Origen DUT model' do

  it "can parse the example" do
    options = {}
    options[:source_dirs] = ["#{Origen.root}/examples/dut/params"]

    begin
      ast = OrigenVerilog.parse_file("#{Origen.root}/examples/dut/dut.v", options)
    rescue SystemExit
    end

    ast.top_level_modules.size.should == 1

    ast.top_level_modules.first.name.should == "dut"

    ast.top_level_modules.first.to_top_level

    dut.should be

    dut.pin(:soc_addr).size.should == 20
  end

end
