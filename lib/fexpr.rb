module Blueprint
  class Fexpr
    attr_reader :variables, :body

    def initialize(variables, body)
      @variables = variables
      @body = body
    end

    def expand(bindings, parent_frame)
      frame = Frame.new(parent_frame)

      variables.zip(bindings).each do |variable, binding|
        frame.define(variable, binding)
      end

      Closure.new([], body, frame)
    end
  end
end
