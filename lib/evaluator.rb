module Blueprint
  Closure = Struct.new(:variables, :body, :env)

  class Evaluator
    PRIMITIVES = [:+, :-, :*, :/, :==]

    def eval(exp, env = global_env)
      if exp.is_a?(Fixnum)
        exp
      elsif exp.is_a?(Symbol)
        env[exp]
      elsif exp.first == :quote
        exp[1]
      elsif exp.first == :lambda
        Closure.new(exp[1], exp[2], env)
      elsif exp.first == :let
        eval(let_to_lambda(exp), env)
      elsif exp.first == :cond
        evcond(exp.drop(1), env)
      else
        apply(
          eval(exp.first, env),
          exp.drop(1).map { |arg| eval(arg, env) },
        )
      end
    end

    private

    def apply(proc, args)
      if primitive?(proc)
        apply_primop(proc, args)
      elsif proc.is_a?(Closure)
        eval(
          proc.body,
          proc.env.merge(proc.variables.zip(args).to_h),
        )
      else
        raise "\"#{proc}\" isn't applicable."
      end
    end

    def let_to_lambda(exp)
      variables = exp[1].map(&:first)
      assignments = exp[1].map(&:last)
      body = exp.drop(2)
      [[:lambda, variables,
          *body],
        *assignments]
    end

    def global_env
      PRIMITIVES.zip(PRIMITIVES).to_h
    end

    def evcond(clauses, env)
      true_clause = clauses.find { |clause|
        clause[0] == :else || eval(clause[0], env)
      }

      if true_clause
        eval(true_clause[1], env)
      else
        []
      end
    end

    def bind(vars, vals, env)
      env.merge(vars.zip(vals).to_h)
    end

    def primitive?(op)
      PRIMITIVES.include?(op)
    end

    def apply_primop(proc, args)
      args.reduce(proc)
    end
  end
end
