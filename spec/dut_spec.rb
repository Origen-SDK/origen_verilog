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

  it "can parse the example with params file given at runtime" do
    options = {}
    options[:source_dirs] = ["#{Origen.root}/examples/dut/params"]

    begin
      ast = OrigenVerilog.parse_file("params.v #{Origen.root}/examples/dut/dut_without_params.v", options)
    rescue SystemExit
    end

    ast.top_level_modules.size.should == 1

    ast.top_level_modules.first.name.should == "dut"

    ast.top_level_modules.first.to_top_level

    dut.should be

    dut.pin(:soc_addr).size.should == 20
  end

  it "can accept defines at runtime" do
    options = {}
    options[:source_dirs] = ["#{Origen.root}/examples/dut/params"]
    options[:defines] = ["ENABLE_PARAMS"]

    begin
      ast = OrigenVerilog.parse_file("params_with_define_wrapper.v #{Origen.root}/examples/dut/dut_without_params.v", options)
    rescue SystemExit
    end

    ast.top_level_modules.size.should == 1

    ast.top_level_modules.first.name.should == "dut"

    ast.top_level_modules.first.to_top_level

    dut.should be

    dut.pin(:soc_addr).size.should == 20
  end

  it "can accept defines with a value at runtime" do
    options = {}
    options[:source_dirs] = ["#{Origen.root}/examples/dut/params"]
    options[:defines] = ["NUMADDR=10"]

    begin
      ast = OrigenVerilog.parse_file("#{Origen.root}/examples/dut/dut_without_params.v", options)
    rescue SystemExit
    end

    ast.top_level_modules.size.should == 1

    ast.top_level_modules.first.name.should == "dut"

    ast.top_level_modules.first.to_top_level

    dut.should be

    dut.pin(:soc_addr).size.should == 10
  end

  it "can identify WREAL pins" do
    options = {}
    options[:source_dirs] = ["#{Origen.root}/examples/dut/params"]
    options[:defines] = ["USE_WREAL"]

    begin
      ast = OrigenVerilog.parse_file("#{Origen.root}/examples/dut/dut.v", options)
    rescue SystemExit
    end

    dut_ast = ast.top_level_modules.first

    dut_ast.pins.size.should == 7
    dut_ast.pins(analog: true).size.should == 3
    dut_ast.pins(digital: true).size.should == 4

    dut_ast.to_top_level

    dut.should be

    dut.pin(:enable).analog?.should == false
    dut.pin(:vdd).analog?.should == true
    dut.pin(:vddc).analog?.should == true
    dut.pin(:vddf).analog?.should == true
  end
end
