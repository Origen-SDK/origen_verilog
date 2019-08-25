module OrigenVerilog
  class TopLevel
    include Origen::TopLevel

    attr_reader :name
    attr_reader :options

    def initialize(options = {})
      @name = options[:ast].to_a[0]
      @options = options

      pins = options[:ast].pins(digital: true).map { |p| [p, :digital] }.to_h
      pins.merge!(options[:ast].pins(analog: true).map { |p| [p, :analog] }.to_h)

      # Override any pin types from the user
      if options[:forced_pin_types]
        pins = pins.map do |pin, type|
          matched = options[:forced_pin_types].any? do |matcher, forced_type|
            if matcher.is_a?(Regexp) && pin.value =~ matcher
              type = forced_type
              true
            elsif pin.value == matcher
              type = forced_type
              true
            end
          end
          matched ? [pin, type] : [pin, type]
        end.to_h
      end
      pins.each { |n, type| _add_pin_(n, type) }
    end

    private

    def pin_role?(role, pin)
      (options[role] || []).each do |matcher|
        if matcher.is_a?(Regexp)
          return true if pin.to_s =~ matcher
        else
          return true if pin.to_s == matcher
        end
      end
      false
    end

    def _add_pin_(node, type)
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
        pin = n.pop
        if pin_role?(:ground_pins, pin)
          add_ground_pin pin.to_sym, direction: direction, size: size, offset: offset, type: type
        elsif pin_role?(:power_pins, pin)
          add_power_pin pin.to_sym, direction: direction, size: size, offset: offset, type: type
        elsif pin_role?(:virtual_pins, pin)
          add_virtual_pin pin.to_sym, direction: direction, size: size, offset: offset, type: type
        elsif pin_role?(:other_pins, pin)
          add_other_pin pin.to_sym, direction: direction, size: size, offset: offset, type: type
        else
          add_pin pin.to_sym, direction: direction, size: size, offset: offset, type: type
        end
      end
    end
  end
end
