require_relative "parser"
require_relative "evaluator"

module Blueprint
  class Repl
    def exec
      print "> "
      while input = gets
        puts interpreter.eval(input)
        print "> "
      end
      puts
    end

    private

    def interpreter
      @_interpreter ||= Interpreter.new
    end
  end
end
