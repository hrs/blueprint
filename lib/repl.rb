require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Repl
    def exec
      print "> "
      while input = gets
        puts format(interpreter.eval(input))
        print "> "
      end
      puts
    end

    private

    def format(expr)
      if expr.is_a?(Array)
        "(#{expr.map { |elt| format(elt) }.join(" ")})"
      elsif expr.is_a?(Closure)
        "#<lambda #{format(expr.variables)} -> #{format(expr.body)}>"
      elsif expr.is_a?(Macro)
        "#<macro #{format(expr.variables)} -> #{format(expr.body)}>"
      else
        expr.to_s
      end
    end

    def interpreter
      @_interpreter ||= Interpreter.new
    end
  end
end
