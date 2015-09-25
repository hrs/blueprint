require_relative "./closure"
require_relative "./macro"

module Blueprint
  class Evaluator
    PRIMITIVES = [:+, :-, :*, :/, :%, :==]

    def initialize
      @env = Environment.new
      initialize_primitives
      initialize_standard_library
      @env.push_frame
    end

    def eval(exp, env = @env)
      if literal?(exp)
        exp
      elsif symbol?(exp)
        env[exp]
      elsif exp == []
        []
      elsif special_form?(exp.first)
        special_forms[exp.first].call(exp, env)
      elsif macro?(exp.first, env)
        eval_macro(exp, env)
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

    def special_forms
      {
        apply: -> (exp, env) {
          apply(
            eval(exp[1], env),
            eval(exp[2], env),
          )
        },
        cond: -> (exp, env) { evcond(exp.drop(1), env) },
        cons: -> (exp, env) { [eval(exp[1], env), *eval(exp[2], env)] },
        define: -> (exp, env) { eval_define(exp, env) },
        defmacro: -> (exp, env) { defmacro(exp, env) },
        eval: -> (exp, env) { eval(eval(exp[1], env), env) },
        first: -> (exp, env) { evfirst(exp, env) },
        lambda: -> (exp, env) { Closure.new(exp[1], exp[2], env) },
        list: -> (exp, env) { exp.drop(1).map { |e| eval(e, env) } },
        :"slurp-file" => -> (exp, env) { File.read(eval(exp[1], env)) },
        quasiquote: -> (exp, env) { expand_quasiquote(exp[1], env) },
        quote: -> (exp, _) { exp[1] },
        read: -> (exp, env) { Parser.new(eval(exp[1], env)).parse },
        rest: -> (exp, env) { evrest(exp, env) },
        set!: -> (exp, env) { env.set!(exp[1], eval(exp[2], env)) },
      }
    end

    def special_form?(symbol)
      special_forms.has_key?(symbol)
    end

    def defmacro(exp, env)
      env[exp[1][0]] = Macro.new(
        exp[1].drop(1),
        exp[2],
      )
    end

    def initialize_primitives
      @env.push_frame(Frame.new(PRIMITIVES, PRIMITIVES))
    end

    def standard_library_file
      File.join(File.dirname(__FILE__), "standard-library.blu")
    end

    def initialize_standard_library
      Interpreter.new.load_file(standard_library_file, self)
    end

    def literal?(exp)
      exp.is_a?(Fixnum) || exp.is_a?(String)
    end

    def symbol?(exp)
      exp.is_a?(Symbol)
    end

    def macro?(symbol, env)
      env.defined?(symbol) && env[symbol].is_a?(Macro)
    end

    def eval_macro(exp, env)
      eval(
        apply(
          env[exp.first].expand(exp.drop(1), env),
          [],
        ),
        env,
      )
    end

    def expand_quasiquote(exp, env)
      if exp == []
        []
      elsif literal?(exp) || symbol?(exp)
        eval([:quote, exp], env)
      elsif exp[0] == :unquote
        eval(exp[1], env)
      else
        exp.map { |e| expand_quasiquote(e, env) }
      end
    end

    def eval_define(exp, env)
      if exp[1].is_a?(Array)
        env[exp[1].first] = Closure.new(exp[1].drop(1), exp[2], env)
      else
        env[exp[1]] = eval(exp[2], env)
      end
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
