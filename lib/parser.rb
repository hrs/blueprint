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
          quote | quasiquote | unquote | unquote_splicing |
          (str("(") >> space? >> str(")")).as(:empty_list) |
          str("(") >> space? >> sexpr.repeat >> str(")")
        ) >>
        space?
      ).as(:sexpr)
    end

    rule(:quote) do
      (str("'") >> sexpr).as(:quote)
    end

    rule(:quasiquote) do
      (str("`") >> sexpr).as(:quasiquote)
    end

    rule(:unquote) do
      (str(",") >> sexpr).as(:unquote)
    end

    rule(:unquote_splicing) do
      (str(",@") >> sexpr).as(:unquote_splicing)
    end

    rule(:atom) do
      float | symbol | integer | string
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

    rule(:float) do
      (
        str("-").maybe >>
        digit.repeat(1) >>
        str(".") >>
        digit.repeat(1)
      ).as(:float)
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
      match(/[a-z]|\-|\+|\*|\/|\#|\=|\!|\?|\%/).repeat(1).as(:symbol)
    end

    rule(:string) do
      str('"') >>
        (
          str('\\') >> any |
          str('"').absent? >> any
        ).repeat.as(:string) >>
        str('"')
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

    rule quote: subtree(:a) do
      [:quote, a]
    end

    rule quasiquote: subtree(:a) do
      [:quasiquote, a]
    end

    rule unquote: subtree(:a) do
      [:unquote, a]
    end

    rule unquote_splicing: subtree(:a) do
      [:"unquote-splicing", a]
    end

    rule integer: simple(:a) do
      a.to_i
    end

    rule float: simple(:a) do
      a.to_f
    end

    rule symbol: simple(:a) do
      a.to_sym
    end

    rule string: simple(:s) do
      s.to_s
    end

    rule empty_list: simple(:a) do
      []
    end
  end
end
