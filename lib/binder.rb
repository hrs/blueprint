module Blueprint
  class Binder
    def initialize(variables, values)
      @variables = variables
      @values = values
    end

    def bind(frame)
      frame.push_with_bindings(bindings)
    end

    private

    attr_reader :variables, :values

    def bindings
      if regular_binding?
        variables.zip(values)
      elsif variadic_binding?
        if rest_term_missized?
          raise "only allowed one variadic argument"
        end
        variadic_bind(
          binding_groups[0],
          binding_groups[1][0],
          values
        )
      else
        raise "can't bind more than one variadic group"
      end
    end

    def regular_binding?
      binding_groups.size <= 1
    end

    def variadic_binding?
      binding_groups.size == 2
    end

    def rest_term_missized?
      binding_groups.last.size != 1
    end

    def variadic_bind(vars, rest, vals)
      bindings = vars.zip(vals).reduce({}) do |acc, var, val|
        acc.merge(var => val)
      end
      bindings[rest] = vals.drop(vars.size)
      bindings
    end

    def binding_groups
      @_binding_groups ||= construct_binding_groups
    end

    def construct_binding_groups
      groups = []
      current_group = []
      variables.each do |variable|
        if variable == :"."
          groups << current_group
          current_group = []
        else
          current_group << variable
        end
      end
      groups << current_group
    end
  end
end
