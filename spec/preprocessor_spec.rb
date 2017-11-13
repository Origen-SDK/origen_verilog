require 'spec_helper'

describe "The Preprocessor" do
  #it "scratch for debug" do
  #  ast = pre_parser.parse_file("#{Origen.root}/examples/scratch.v")
  #  ast.should be
  #  debugger
  #end

  it "it can parse the examples" do
    output_dir = "#{Origen.root}/output/preprocessor"
    approved_dir = "#{Origen.root}/approved/preprocessor"
    FileUtils.mkdir_p "#{output_dir}/picosoc"
    passed = true
    {
      "picosoc/picorv32.v" => {},
      "picosoc/picosoc.v" => {},
      "picosoc/simpleuart.v" => {},
      "picosoc/spimemio.v" => {},
      "test.v" => {source_dirs: ["#{Origen.root}/examples/dir1"]}
    }.each do |file, env|
      pre_parser.parse_file("#{Origen.root}/examples/#{file}").
        process("#{output_dir}/#{file}", env)

      new = File.read("#{output_dir}/#{file}")
      old = File.read("#{approved_dir}/#{file}")

      if new != old
        puts "**** DIFF Detected ****"
        puts "tkdiff #{approved_dir}/#{file} #{output_dir}/#{file} &"
        puts "cp  #{output_dir}/#{file} #{approved_dir}/#{file}"
        passed = fail
      end
    end
    passed.should == true
  end

  it "can read comments" do
    pre_parser.parse("// Hello\n// Yo\n").should ==
      s(:source,
        s(:comment, "// Hello"),
        s(:text_block, "\n"),
        s(:comment, "// Yo"),
        s(:text_block, "\n"))
  end

  it "can read defines" do
    pre_parser.parse("`define BLAH").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH")))

    pre_parser.parse("`define BLAH(arg1, arg2)").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH",
            s(:arguments, "arg1", "arg2"))))

    pre_parser.parse("`define BLAH some text").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH"),
          s(:text, "some text")))

    pre_parser.parse("`define BLAH(arg1, arg2) some text").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH",
            s(:arguments, "arg1", "arg2")),
          s(:text, "some text")))

    pre_parser.parse("`define BLAH(arg1, arg2) some text\n multi line").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH",
            s(:arguments, "arg1", "arg2")),
          s(:text, "some text")),
        s(:text_block, "\n multi line"))

    pre_parser.parse("`define BLAH(arg1, arg2) some text \\ \n multi line").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH",
            s(:arguments, "arg1", "arg2")),
          s(:text, "some text \n multi line")))

    pre_parser.parse("`define BLAH some text // should not see me!").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH"),
          s(:text, "some text")),
        s(:comment, "// should not see me!"))

    pre_parser.parse("`define BLAH(arg1)\nnext line").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH",
            s(:arguments, "arg1"))),
        s(:text_block, "\nnext line"))

    pre_parser.parse("`define BLAH\nyo").should ==
      s(:source,
        s(:define,
          s(:name, "BLAH")),
        s(:text_block, "\nyo"))
  end

  it "can read undefs" do
    pre_parser.parse("`undef BLAH").should ==
      s(:source,
        s(:undef, "BLAH"))
  end

  it "can read includes" do
    pre_parser.parse('`include "parts/count.v"').should ==
      s(:source,
        s(:include, "parts/count.v"))

    pre_parser.parse('`include "/parts/count.v"').should ==
      s(:source,
        s(:include, "/parts/count.v"))

    pre_parser.parse('`include "C:/parts/count.v"').should ==
      s(:source,
        s(:include, "C:/parts/count.v"))

    pre_parser.parse('`include "fileB"').should ==
      s(:source,
        s(:include, "fileB"))

    pre_parser.parse('`include "fileB" // including fileB').should ==
      s(:source,
        s(:include, "fileB"),
        s(:text_block, " "),
        s(:comment, "// including fileB"))
  end

  it "can read macro references" do
    pre_parser.parse('`BLAH').should ==
      s(:source,
        s(:macro_reference, "BLAH"))

    pre_parser.parse('// `BLAH').should ==
      s(:source,
        s(:comment, "// `BLAH"))

     pre_parser.parse('`assert(!mem_do_prefetch && !mem_do_rinst)').should ==
      s(:source,
        s(:macro_reference, "assert",
          s(:arguments, "!mem_do_prefetch && !mem_do_rinst")))

     pre_parser.parse('`blah(arg1, arg2)').should ==
      s(:source,
        s(:macro_reference, "blah",
          s(:arguments, "arg1", "arg2")))

     pre_parser.parse('`debug($display("ST_RD:  %2d 0x%08x, BRANCH 0x%08x", latched_rd, reg_pc + (latched_compr ? 2 : 4), current_pc);)').should ==
      s(:source,
        s(:macro_reference, "debug",
          s(:arguments, '$display("ST_RD:  %2d 0x%08x, BRANCH 0x%08x", latched_rd, reg_pc + (latched_compr ? 2 : 4), current_pc);')))
  end

  it "can read ifdefs" do

    src = 
%{`ifdef DEBUG
Some code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifdef, "DEBUG",
          s(:text_block, "\nSome code\n")))

    src = 
%{`ifdef DEBUG
Some code
`elsif BLAH
Blah
`else
Some other code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifdef, "DEBUG",
          s(:text_block, "\nSome code\n"),
          s(:elsif, "BLAH",
            s(:text_block, "\nBlah\n")),
          s(:else,
            s(:text_block, "\nSome other code\n"))))

    src = 
%{`ifdef DEBUG
Some code
`elsif BLAH
Blah
`elsif BLAH2
Blah2
`else
Some other code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifdef, "DEBUG",
          s(:text_block, "\nSome code\n"),
          s(:elsif, "BLAH",
            s(:text_block, "\nBlah\n")),
          s(:elsif, "BLAH2",
            s(:text_block, "\nBlah2\n")),
          s(:else,
            s(:text_block, "\nSome other code\n"))))
  end

  it "can read ifndefs" do

    src = 
%{`ifndef DEBUG
Some code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifndef, "DEBUG",
          s(:text_block, "\nSome code\n")))

    src = 
%{`ifndef DEBUG
Some code
`elsif BLAH
Blah
`else
Some other code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifndef, "DEBUG",
          s(:text_block, "\nSome code\n"),
          s(:elsif, "BLAH",
            s(:text_block, "\nBlah\n")),
          s(:else,
            s(:text_block, "\nSome other code\n"))))

    src = 
%{`ifndef DEBUG
Some code
`elsif BLAH
Blah
`elsif BLAH2
Blah2
`else
Some other code
`endif}
    pre_parser.parse(src).should ==
      s(:source,
        s(:ifndef, "DEBUG",
          s(:text_block, "\nSome code\n"),
          s(:elsif, "BLAH",
            s(:text_block, "\nBlah\n")),
          s(:elsif, "BLAH2",
            s(:text_block, "\nBlah2\n")),
          s(:else,
            s(:text_block, "\nSome other code\n"))))
  end
end
