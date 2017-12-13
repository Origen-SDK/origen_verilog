[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Origen-SDK/users?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Origen-SDK/origen_verilog.svg?branch=master)](https://travis-ci.org/Origen-SDK/origen_verilog)
[![Coverage Status](https://coveralls.io/repos/github/Origen-SDK/origen_verilog/badge.svg?branch=master)](https://coveralls.io/github/Origen-SDK/origen_verilog?branch=master)

# OrigenVerilog

This plugin provides the following functionality to help interface Origen applications with design
IP written in Verilog:

* A verilog parser which should be able to parse any legal Verilog code into an abstract syntax tree (AST)
  representation
* A pre-processor which can resolve and apply all compiler directives in the AST, such as defines and ifdefs
* APIs to convert AST nodes into Origen models

### Examples

Parse a top-level Verilog file into an AST:

~~~ruby
ast = OrigenVerilog.parse_file("/path/to/my_product.v")
~~~

Convert the first module in the AST to an Origen top-level model:

~~~ruby
ast.modules.first.to_top_level # Creates dut

dut.pins.size   # => 60 (for example, depends on what was in the Verilog source)
~~~
