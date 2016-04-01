require_relative "./closure"
require_relative "./fexpr"

module Blueprint
  class Formatter
    def initialize(expression, quote_strings: false)
      @expression = expression
      @quote_strings = quote_strings
    end

    def format
      case expression
      when Array
        format_as_list
      when Closure
        format_as_closure
      when Fexpr
        format_as_fexpr
      when String
        if quote_strings?
          "\"#{expression}\""
        else
          expression
        end
      else
        expression.to_s
      end
    end

    private

    attr_reader :expression

    def quote_strings?
      @quote_strings
    end

    def format_as_list
      if expression.first == :quote
        "'#{subformat(expression.last)}"
      elsif expression.first == :quasiquote
        "`#{subformat(expression.last)}"
      elsif expression.first == :unquote
        ",#{subformat(expression.last)}"
      elsif expression.first == :"unquote-splicing"
        ",@#{subformat(expression.last)}"
      else
        "(#{expression.map { |elt| subformat(elt)}.join(" ")})"
      end
    end

    def format_as_closure
      "#<lambda " +
        subformat(expression.variables) +
        ">"
    end

    def format_as_fexpr
      "#<fexpr " +
        subformat(expression.variables) +
        ">"
    end

    def subformat(str)
      self.class.new(str, quote_strings: quote_strings?).format
    end
  end
end
