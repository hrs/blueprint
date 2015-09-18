require_relative "lexer"
require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Repl
    def exec
      print "> "
      while input = gets
        puts exec_line(input)
        print "> "
      end
    end

    private

    def exec_line(input)
      tokens = Lexer.new(input.strip).tokenize
      ast = Parser.new.parse(tokens)
      evaluator = Evaluator.new

      ast.map { |expr| evaluator.eval(expr) }.join("\n")
    end
  end
end
