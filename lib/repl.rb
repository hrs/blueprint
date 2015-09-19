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
      ast = Blueprint::Parser.new(input).parse
      evaluator = Evaluator.new

      ast.map { |expr| evaluator.eval(expr) }.join("\n")
    end
  end
end
