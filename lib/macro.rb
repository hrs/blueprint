module Blueprint
  Macro = Struct.new(:variables, :body) do
    def expand(bindings, parent_frame)
      frame = Frame.new(parent_frame)
      variables.zip(bindings).each do |var, val|
        frame.define(var, val)
      end
      Closure.new([], body, frame)
    end
  end
end
