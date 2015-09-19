require "parslet"

module Blueprint
  class Parser < Parslet::Parser
    def initialize(input)
      @input = input
    end

    def parse
      Transformer.new.apply(super(@input))
    end

    root(:program)

    rule(:program) do
      sexpr.repeat.as(:program)
    end

    rule(:sexpr) do
      (
        space? >>
        (
          atom |
          str("(") >> sexpr.repeat >> str(")")
        ) >>
        space?
      ).as(:sexpr)
    end

    rule(:atom) do
      symbol | integer
    end

    rule(:integer) do
      (
        zero |
        (
          str("-").maybe >>
          nonzero >>
          digit.repeat
        )
      ).as(:integer)
    end

    rule(:digit) do
      match("[0-9]")
    end

    rule(:nonzero) do
      match("[1-9]")
    end

    rule(:zero) do
      str("0")
    end

    rule(:symbol) do
      match(/[a-z]|\-|\+|\*|\/|\#/).repeat(1).as(:symbol)
    end

    rule(:space?) do
      match(/\s/).repeat
    end
  end

  class Transformer < Parslet::Transform
    rule sexpr: subtree(:a) do
      a
    end

    rule program: subtree(:a) do
      a
    end

    rule integer: simple(:a) do
      a.to_i
    end

    rule symbol: simple(:a) do
      a.to_sym
    end
  end
end