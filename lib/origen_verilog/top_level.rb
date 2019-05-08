module OrigenVerilog
  class TopLevel
    include Origen::TopLevel

    attr_reader :name

    def initialize(options = {})
      @name = options[:ast].to_a[0]

      options[:ast].pins(digital: true).each { |n| _add_pin_(n) }
      options[:ast].pins(analog: true).each { |n| _add_pin_(n, true) }
    end

    private

    def _add_pin_(node, analog = false)
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
        offset = r.to_a[1]
      else
        size = 1
        offset = nil
      end
      n = node.to_a.dup
      while n.last.is_a?(String)
        add_pin n.pop.to_sym, direction: direction, size: size, offset: offset, analog: analog
      end
    end
  end
end
