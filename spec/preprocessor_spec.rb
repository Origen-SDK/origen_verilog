require 'spec_helper'

describe "The Preprocessor" do
  #it "scratch for debug" do
  #  ast = pre_parser.parse_file("#{Origen.root}/examples/scratch.v")
  #  ast.should be
  #  debugger
  #end

  it "it can parse the examples" do
    %w(picorv32 picosoc simpleuart spimemio).each do |file|
      pre_parser.parse_file("#{Origen.root}/examples/picosoc/#{file}.v").should be
    end
  end

  it "can read defines" do
    pre_parser.parse("`define BLAH").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH")))

    pre_parser.parse("`define BLAH(arg1, arg2)").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH",
            s(:list_of_formal_arguments, "arg1", "arg2"))))

    pre_parser.parse("`define BLAH some text").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH"),
          s(:macro_text, "some text")))

    pre_parser.parse("`define BLAH(arg1, arg2) some text").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH",
            s(:list_of_formal_arguments, "arg1", "arg2")),
          s(:macro_text, "some text")))

    pre_parser.parse("`define BLAH(arg1, arg2) some text\n multi line").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH",
            s(:list_of_formal_arguments, "arg1", "arg2")),
          s(:macro_text, "some text")),
        s(:text_block, "\n multi line"))

    pre_parser.parse("`define BLAH(arg1, arg2) some text \\ \n multi line").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH",
            s(:list_of_formal_arguments, "arg1", "arg2")),
          s(:macro_text, "some text \n multi line")))

    pre_parser.parse("`define BLAH some text // should not see me!").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH"),
          s(:macro_text, "some text")),
        s(:comment, "// should not see me!"))

    pre_parser.parse("`define BLAH(arg1)\nnext line").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH",
            s(:list_of_formal_arguments, "arg1"))),
        s(:text_block, "\nnext line"))

    pre_parser.parse("`define BLAH\nyo").should ==
      s(:source,
        s(:text_macro_definition,
          s(:text_macro_name, "BLAH")),
        s(:text_block, "\nyo"))
  end

  it "can read undefs" do
    pre_parser.parse("`undef BLAH").should ==
      s(:source,
        s(:undefine_compiler_directive, "BLAH"))
  end

  it "can read includes" do
    pre_parser.parse('`include "parts/count.v"').should ==
      s(:source,
        s(:include_compiler_directive, "parts/count.v"))

    pre_parser.parse('`include "/parts/count.v"').should ==
      s(:source,
        s(:include_compiler_directive, "/parts/count.v"))

    pre_parser.parse('`include "C:/parts/count.v"').should ==
      s(:source,
        s(:include_compiler_directive, "C:/parts/count.v"))

    pre_parser.parse('`include "fileB"').should ==
      s(:source,
        s(:include_compiler_directive, "fileB"))

    pre_parser.parse('`include "fileB" // including fileB').should ==
      s(:source,
        s(:include_compiler_directive, "fileB"),
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
