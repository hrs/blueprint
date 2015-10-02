require_relative "./binder"
require_relative "./closure"
require_relative "./macro"

module Blueprint
  class Evaluator
    PRIMITIVES = [:+, :-, :*, :/, :%, :==]

    def initialize
      @global_frame = Frame.new(initialize_primitives)
      initialize_standard_library
      @global_frame = Frame.new(@global_frame)
    end

    def eval(exp, frame = @global_frame)
      if literal?(exp)
        exp
      elsif symbol?(exp)
        frame.lookup(exp)
      elsif exp == []
        []
      elsif special_form?(exp.first)
        special_forms[exp.first].call(exp, frame)
      elsif macro?(exp.first, frame)
        eval_macro(exp, frame)
      else
        apply(
          eval(exp.first, frame),
          exp.drop(1).map { |arg| eval(arg, frame) },
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
          bind(proc.variables, args, proc.frame),
        )
      else
        raise "\"#{proc}\" isn't applicable."
      end
    end

    def special_forms
      {
        :"->string" => -> (exp, frame) {
          Formatter.new(eval(exp[1], frame)).format
        },
        apply: -> (exp, frame) {
          apply(
            eval(exp[1], frame),
            eval(exp[2], frame),
          )
        },
        cond: -> (exp, frame) { evcond(exp.drop(1), frame) },
        cons: -> (exp, frame) { [eval(exp[1], frame), *eval(exp[2], frame)] },
        define: -> (exp, frame) { eval_define(exp, frame) },
        defmacro: -> (exp, frame) { defmacro(exp, frame) },
        display: -> (exp, frame) { print(eval(exp[1], frame)) },
        exit: -> (exp, frame) { exit(eval(exp[1], frame)) },
        eval: -> (exp, frame) { eval(eval(exp[1], frame), frame) },
        first: -> (exp, frame) { evfirst(exp, frame) },
        lambda: -> (exp, frame) { Closure.new(exp[1], exp[2], frame) },
        list: -> (exp, frame) { exp.drop(1).map { |e| eval(e, frame) } },
        load: -> (exp, frame) { Interpreter.new.load_file(exp[1], self) },
        :"slurp-file" => -> (exp, frame) { File.read(eval(exp[1], frame)) },
        quasiquote: -> (exp, frame) { expand_quasiquote(exp[1], frame) },
        quote: -> (exp, _) { exp[1] },
        read: -> (exp, frame) { Parser.new(eval(exp[1], frame)).parse },
        rest: -> (exp, frame) { evrest(exp, frame) },
        set!: -> (exp, frame) { frame.set!(exp[1], eval(exp[2], frame)) },
      }
    end

    def special_form?(symbol)
      special_forms.has_key?(symbol)
    end

    def defmacro(exp, frame)
      frame.define(
        exp[1][0],
        Macro.new(
          exp[1].drop(1),
          exp[2],
        )
      )
    end

    def initialize_primitives
      Frame.new.push_with_bindings(
        PRIMITIVES.zip(PRIMITIVES)
      )
    end

    def standard_library_file
      File.join(File.dirname(__FILE__), "standard-library.blu")
    end

    def initialize_standard_library
      Interpreter.new.load_file(standard_library_file, self)
    end

    def literal?(exp)
      exp.is_a?(Fixnum) ||
        exp.is_a?(Float) ||
        exp.is_a?(String) ||
        exp == true ||
        exp == false
    end

    def symbol?(exp)
      exp.is_a?(Symbol)
    end

    def macro?(symbol, frame)
      frame.defined?(symbol) && frame.lookup(symbol).is_a?(Macro)
    end

    def eval_macro(exp, frame)
      eval(
        apply(
          frame.lookup(exp.first).expand(exp.drop(1), frame),
          [],
        ),
        frame,
      )
    end

    def expand_quasiquote(exp, frame)
      if exp == []
        []
      elsif literal?(exp) || symbol?(exp)
        eval([:quote, exp], frame)
      elsif exp[0] == :unquote
        eval(exp[1], frame)
      elsif exp[0] == :"unquote-splicing"
        raise "can't splice without an enclosing list"
      else
        exp.reduce([]) { |acc, e|
          if e.is_a?(Array) && e[0] == :"unquote-splicing"
            acc += eval(e[1], frame)
          else
            acc += [expand_quasiquote(e, frame)]
          end
        }
      end
    end

    def eval_define(exp, frame)
      if exp[1].is_a?(Array)
        frame.define(exp[1].first, Closure.new(exp[1].drop(1), exp[2], frame))
      else
        frame.define(exp[1], eval(exp[2], frame))
      end
    end

    def evcond(clauses, frame)
      true_clause = clauses.find { |clause|
        clause[0] == :else || eval(clause[0], frame)
      }

      if true_clause
        eval(true_clause[1], frame)
      else
        []
      end
    end

    def evfirst(exp, frame)
      result = eval(exp[1], frame)

      if result.respond_to?(:size) && result.size > 0
        result.first
      else
        raise "can't get \"first\" of \"#{result}\""
      end
    end

    def evrest(exp, frame)
      result = eval(exp[1], frame)

      if result.respond_to?(:size) && result.size > 0
        result.drop(1)
      else
        raise "can't get \"rest\" of \"#{result}\""
      end
    end

    def bind(vars, vals, frame)
      Binder.new(vars, vals).bind(frame)
    end

    def primitive?(op)
      PRIMITIVES.include?(op)
    end

    def apply_primop(proc, args)
      args.reduce(proc)
    end
  end
end
