require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Interpreter
    def eval(input, evaluator = current_evaluator)
      Parser.new(input).parse.
        map { |expr| evaluator.eval(expr) }.
        last
    end

    def load_file(filename, evaluator = current_evaluator)
      eval(File.read(filename), evaluator)
    end

    private

    def current_evaluator
      @_current_evaluator ||= Evaluator.new
    end
  end
end
