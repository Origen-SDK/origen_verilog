module OrigenVerilog
  class TopLevel
    include Origen::TopLevel

    attr_reader :name

    def initialize(options = {})
      @name = options[:ast].to_a[0]

      options[:ast].pins.each do |node|
        node = node.evaluate  # Resolve any functions in the ranges
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
        n = node.to_a.dup
        while n.last.is_a?(String)
          add_pin n.pop, direction: direction, size: size
        end
      end
    end
  end
end
