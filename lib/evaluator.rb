module Blueprint
  Closure = Struct.new(:variables, :body, :env)

  class Evaluator
    PRIMITIVES = [:+, :-, :*, :/, :==]

    def initialize
      @env = Environment.new
      initialize_primitives
      initialize_standard_library
    end

    def eval(exp, env = @env)
      if exp.is_a?(Fixnum)
        exp
      elsif exp.is_a?(Symbol)
        env[exp]
      elsif exp.first == :quote
        exp[1]
      elsif exp.first == :define
        if exp[1].is_a?(Array)
          env[exp[1].first] = Closure.new(exp[1].drop(1), exp[2], env)
        else
          env[exp[1]] = eval(exp[2], env)
        end
      elsif exp.first == :set!
        env.set!(exp[1], eval(exp[2], env))
      elsif exp.first == :cons
        [eval(exp[1], exp), *eval(exp[2], env)]
      elsif exp.first == :first
        evfirst(exp, env)
      elsif exp.first == :rest
        evrest(exp, env)
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
        proc.env.push_frame(Frame.new(proc.variables, args))
        eval(
          proc.body,
          proc.env,
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

    def initialize_primitives
      @env.push_frame(Frame.new(PRIMITIVES, PRIMITIVES))
    end

    def initialize_standard_library
      lib = {
        :null? => Closure.new([:exp], [:==, :exp, [:quote, []]], @env),
      }
      @env.push_frame(Frame.new(lib.keys, lib.values))
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

    def evfirst(exp, env)
      result = eval(exp[1], env)

      if result.respond_to?(:size) && result.size > 0
        result.first
      else
        raise "can't get \"first\" of \"#{result}\""
      end
    end

    def evrest(exp, env)
      result = eval(exp[1], env)

      if result.respond_to?(:size) && result.size > 0
        result.drop(1)
      else
        raise "can't get \"rest\" of \"#{result}\""
      end
    end

    def bind(vars, vals, env)
      env.push_frame(Frame.new(vars, vals))
      env
    end

    def primitive?(op)
      PRIMITIVES.include?(op)
    end

    def apply_primop(proc, args)
      args.reduce(proc)
    end
  end
end
