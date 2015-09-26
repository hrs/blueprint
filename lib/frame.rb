module Blueprint
  class Frame
    def initialize(parent = NullFrame.new)
      @parent = parent
      @bindings = {}
    end

    def push_with_bindings(new_bindings)
      Frame.new(self).tap { |child|
        new_bindings.each do |var, val|
          child.define(var, val)
        end
      }
    end

    def define(symbol, value)
      bindings[symbol] = value
    end

    def set!(symbol, value)
      if bindings.has_key?(symbol)
        bindings[symbol] = value
      else
        parent.set!(symbol, value)
      end
    end

    def defined?(symbol)
      bindings.has_key?(symbol) || parent.defined?(symbol)
    end

    def lookup(symbol)
      bindings.fetch(symbol) { parent.lookup(symbol) }
    end

    private

    attr_reader :bindings, :parent

    class NullFrame
      def defined?(_)
        false
      end

      def set!(symbol, _)
        raise "can't set unbound symbol \"#{symbol}\""
      end

      def lookup(symbol)
        raise("symbol \"#{symbol}\" is unbound")
      end
    end
  end
end
