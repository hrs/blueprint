require_relative "../lib/blueprint"

def interpreter
  Blueprint::Interpreter.new
end

def expect_eval(expression)
  expect(interpreter.eval(expression))
end
