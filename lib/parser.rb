require "parslet"
require_relative "./transformer"

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
        comment.maybe >>
        space? >>
        (
          boolean |
          atom |
          quote | quasiquote | unquote | unquote_splicing |
          (str("(") >> space? >> str(")")).as(:empty_list) |
          str("(") >> space? >> sexpr.repeat >> str(")")
        ) >>
        space?
      ).as(:sexpr)
    end

    rule(:comment) do
      str("#") >> match(/[^\n]/).repeat >> str("\n")
    end

    rule(:boolean) do
      (str("true") | str("false")).as(:boolean)
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
      match(/[a-z]|\-|\+|\*|\/|\=|\!|\?|\%|\.|>|</).repeat(1).as(:symbol)
    end

    rule(:string) do
      str('"') >>
        (
          str('\\') >> any |
          str('"').absent? >> any
        ).repeat.maybe.as(:string) >>
        str('"')
    end

    rule(:space?) do
      match(/\s/).repeat
    end
  end
end
