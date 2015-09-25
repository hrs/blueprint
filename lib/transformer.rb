require "parslet"

module Blueprint
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

    rule boolean: simple(:bool) do
      bool == "true"
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
