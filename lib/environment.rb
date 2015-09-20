module Blueprint
  class Frame < Hash
    def initialize(variables = [], values = [])
      merge!(variables.zip(values).to_h)
    end
  end

  class Environment
    def initialize
      @stack = [Frame.new]
    end

    def [](symbol)
      lookup(symbol) || raise("symbol \"#{symbol}\" is unbound")
    end

    def []=(symbol, value)
      stack.last[symbol] = value
    end

    def defined?(symbol)
      !!lookup_frame_with(symbol)
    end

    def set!(symbol, value)
      if defined?(symbol)
        lookup_frame_with(symbol)[symbol] = value
      else
        raise "can't set unbound symbol \"#{symbol}\""
      end
    end

    def push_frame(frame = Frame.new)
      stack.push(frame)
    end

    def pop_frame
      if stack.size > 1
        stack.pop
      else
        raise "can't pop the global frame"
      end
    end

    def to_s
      stack.map { |frame|
        frame.map { |symbol, value|
          "#{symbol}: #{value}"
        }.join("\n")
      }.join("\n--------------------\n")
    end

    private

    attr_accessor :stack

    def lookup(symbol)
      frame = lookup_frame_with(symbol)
      frame && frame[symbol]
    end

    def lookup_frame_with(symbol)
      stack.select { |frame| frame.has_key?(symbol) }.compact.last
    end
  end
end
