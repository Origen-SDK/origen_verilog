require 'spec_helper'

describe "The Verilog Parser" do

  it "it can parse the examples" do
    output_dir = "#{Origen.root}/output/verilog"
    FileUtils.mkdir_p "#{output_dir}/picosoc"
    passed = true
    {
      "picosoc/picorv32.v" => {},
      #"picosoc/picosoc.v" => {},
      #"picosoc/simpleuart.v" => {},
      #"picosoc/spimemio.v" => {},
      #"test.v" => {source_dirs: ["#{Origen.root}/examples/dir1"]}
    }.each do |file, env|
      ast = nil
      begin
        ast = verilog_parser.parse_file("#{Origen.root}/approved/preprocessor/#{file}").to_ast
      rescue SystemExit
      end
      ast.should be
    end
    passed.should == true
  end
end
