require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Interpreter
    def eval(input, evaluator = evaluator)
      Parser.new(input).parse.
        map { |expr| evaluator.eval(expr) }.
        last
    end

    def load_file(filename, evaluater = evaluator)
      eval(File.read(filename), evaluater)
    end

    private

    def evaluator
      @_evaluator ||= Evaluator.new
    end
  end
end
