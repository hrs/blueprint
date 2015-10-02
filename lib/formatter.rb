require_relative "./closure"
require_relative "./macro"

module Blueprint
  class Formatter
    def initialize(expression)
      @expression = expression
    end

    def format
      case expression
      when Array
        format_as_list
      when Closure
        format_as_closure
      when Macro
        format_as_macro
      when String
        "\"#{expression}\""
      else
        expression.to_s
      end
    end

    private

    def format_as_list
      if expression.first == :quote
        "'#{self.class.new(expression.last).format}"
      elsif expression.first == :quasiquote
        "`#{self.class.new(expression.last).format}"
      elsif expression.first == :unquote
        ",#{self.class.new(expression.last).format}"
      elsif expression.first == :"unquote-splicing"
        ",@#{self.class.new(expression.last).format}"
      else
        "(#{expression.map { |elt| self.class.new(elt).format }.join(" ")})"
      end
    end

    def format_as_closure
      "#<lambda " +
        self.class.new(expression.variables).format +
        ">"
    end

    def format_as_macro
      "#<macro " +
        self.class.new(expression.variables).format +
        ">"
    end

    attr_reader :expression
  end
end
