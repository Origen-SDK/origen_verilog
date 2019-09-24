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

The pin types OrigenVerilog comes up with can be overridden, either with `Strings`,
which much be an exact match, or using `Regexp`s. These are be given as a `Hash`
whose keys are pin names or regexes to try and the value are the overridden type.

~~~ruby
# Creates dut with pin types overridden, forcing all pins matching /vdd/ to be digital
# and 'enable' to be analog.
ast.modules.first.to_top_level(forced_pin_types: {'enable' => :analog, /vdd/ => :digital})
~~~

*Important:* If a pin matches multiple keys of the input, the first match will
be used. Care must be taken if overlapping regexes or pin names are given.

Pin roles are also given as an array of regexes or pin names to match. Pin roles indicate whether a given pin
should be added as a `power pin`, `ground pin`, 'virtual pin`, or `other pin`.

~~~ruby
# Creates dut with power pins matching /vdd/, ground pins matching /gnd/,
# 'pta1' and 'pta2' and other pins, and 'vt' as a virtual pin
dut_ast.to_top_level(power_pins: [/vdd/], ground_pins: [/gnd/], other_pins: ['pta1', 'pta2'], virtual_pins: ['vt'])
~~~

Additional files can be given up front, for example a parameters file:

~~~ruby
ast = OrigenVerilog.parse_file("/path/to/my_params.v /path/to/my_product.v")
~~~

Source directories to look for the given files (and any include statement file references within those files) can be given
via an option, rather than supplying absolute paths if you prefer:

~~~ruby
ast = OrigenVerilog.parse_file("my_params.v my_product.v", source_dirs: ["/path/to"])
~~~

Basic compiler defines can also be given:

~~~ruby
ast = OrigenVerilog.parse_file("/path/to/my_product.v", defines: ["ADDR_WIDTH=10", "ENABLE_BLAH"])
~~~
