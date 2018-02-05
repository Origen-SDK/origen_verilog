require 'optparse'
require 'origen_verilog'

options = { source_dirs: [] }

# App options are options that the application can supply to extend this command
app_options = @application_options || []
opt_parser = OptionParser.new do |opts|
  opts.banner = <<-EOT
Parse the given top-level verilog file and convert the top-level module to an Origen top-level
model.
Usage: origen parse TOP_LEVEL_RTL_FILE [options]
  EOT
  opts.on('-t', '--top NAME', String, 'Specify the top-level Verilog module name if OrigenSim can\'t work it out') { |t| options[:top_level_name] = t }
  opts.on('-s', '--source_dir PATH', 'Directories to look for include files in (the directory containing the top-level is already considered)') do |path|
    options[:source_dirs] << path
  end
  opts.on('-d', '--debugger', 'Enable the debugger') {  options[:debugger] = true }
  app_options.each do |app_option|
    opts.on(*app_option) {}
  end
  opts.separator ''
  opts.on('-h', '--help', 'Show this message') { puts opts; exit 0 }
end

opt_parser.parse! ARGV

unless ARGV.size > 0
  puts 'You must supply a path to the top-level RTL file'
  exit 1
end
rtl_top = ARGV.first
unless File.exist?(rtl_top)
  puts "File does not exist: #{rtl_top}"
  exit 1
end

ast = OrigenVerilog.parse_file(rtl_top)

unless ast
  puts 'Sorry, but the given top-level RTL file failed to parse'
  exit 1
end

candidates = ast.top_level_modules
candidates = ast.modules if candidates.empty?

if candidates.size == 0
  puts "Sorry, couldn't find any Verilog module declarations in that file"
  exit 1
elsif candidates.size > 1
  if options[:top_level_name]
    mod = candidates.find { |c| c.name == options[:top_level_name] }
  end
  unless mod
    puts "Sorry, couldn't work out what the top-level module is, please help by running again and specifying it via the --top switch with one of the following names:"
    candidates.each do |c|
      puts "  #{c.name}"
    end
    exit 1
  end
else
  mod = candidates.first
end

rtl_top_module = mod.name

mod.to_top_level # Creates dut
