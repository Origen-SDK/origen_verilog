require 'spec_helper'

describe "The Compiler Directive Parser" do
  it "scratch for debug" do
    raw = pre_parser.parse_file("#{Origen.root}/examples/scratch.v")
    raw.should be
    ast = raw.to_ast
    debugger
  end

  it "can read defines" do
    verilog_parser.parse("`define BLAH").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH"))))

    verilog_parser.parse("`define BLAH(arg1, arg2)").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH",
              s(:list_of_formal_arguments, "arg1", "arg2")))))

    verilog_parser.parse("`define BLAH some text").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH"),
            s(:macro_text, "some text"))))

    verilog_parser.parse("`define BLAH(arg1, arg2) some text").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH",
              s(:list_of_formal_arguments, "arg1", "arg2")),
            s(:macro_text, "some text"))))

    verilog_parser.parse("`define BLAH(arg1, arg2) some text\n multi line", quiet: true).should_not be

    verilog_parser.parse("`define BLAH(arg1, arg2) some text \\ \n multi line").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH",
              s(:list_of_formal_arguments, "arg1", "arg2")),
            s(:macro_text, "some text \n multi line"))))

    verilog_parser.parse("`define BLAH some text // should not see me!").to_ast.should ==
      s(:verilog_source,
        s(:compiler_directive,
          s(:text_macro_definition,
            s(:text_macro_name, "BLAH"),
            s(:macro_text, "some text"))))
  end
end
