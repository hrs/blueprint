require_relative "parser"
require_relative "evaluator"
require_relative "formatter"

module Blueprint
  class Repl
    def exec
      print "> "
      while input = gets
        puts Formatter.new(interpreter.eval(input)).format
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
