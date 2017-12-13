module OrigenVerilog
  class TopLevel
    include Origen::TopLevel

    attr_reader :name

    def initialize(options = {})
      @name = options[:ast].to_a[0]

      options[:ast].pins.each do |node|
        name = node.to_a.last
        if node.type == :input_declaration
          direction = :input
        elsif node.type == :ouput_declaration
          direction = :output
        else
          direction = :io
        end
        if r = node.find(:range)
          size = r.to_a[0] - r.to_a[1] + 1
        else
          size = 1
        end
        add_pin name, direction: direction, size: size
      end
    end
  end
end