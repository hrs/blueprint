module Blueprint
  Macro = Struct.new(:variables, :body) do
    def expand(bindings, env)
      env.push_frame(Frame.new(variables, bindings))
      Closure.new([], body, env)
    end
  end
end
