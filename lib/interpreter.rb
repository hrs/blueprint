require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Interpreter
    def eval(input)
      ast = Parser.new(input).parse
      ast.map { |expr| evaluator.eval(expr) }.last
    end

    private

    def evaluator
      @_evaluator ||= Evaluator.new
    end
  end
end
