require "spec_helper"

describe Blueprint::Interpreter do
  def interpreter
    described_class.new
  end

  it "handles basic arithmetic" do
    expect(interpreter.eval("(+ 1 2 3)")).to eq(6)
  end

  it "handles quotes" do
    expect(interpreter.eval("(quote (1 2 3))")).to eq([1, 2, 3])
  end

  it "handles conditionals" do
    expect(interpreter.eval("(cond ((== 1 2) 3) (else 4))")).to eq(4)
    expect(interpreter.eval("(cond ((== 1 1) 3) (else 4))")).to eq(3)
  end

  it "handles cons" do
    expect(interpreter.eval("(cons 1 (quote ()))")).to eq([1])
    expect(interpreter.eval("(cons 1 (quote (2 3)))")).to eq([1, 2, 3])
    expect(
      interpreter.eval("(cons (quote (1 2)) (quote (3 4)))")
    ).to eq([[1, 2], 3, 4])
  end

  it "handles first" do
    expect(interpreter.eval("(first (quote (1 2 3)))")).to eq(1)
    expect {
      interpreter.eval("(first (quote ()))")
    }.to raise_error(StandardError)
  end

  it "handles rest" do
    expect(interpreter.eval("(rest (quote (1)))")).to eq([])
    expect(interpreter.eval("(rest (quote (1 2 3 4)))")).to eq([2, 3, 4])
    expect {
      interpreter.eval("(rest (quote ()))")
    }.to raise_error(StandardError)
  end

  it "handles list" do
    expect(interpreter.eval("(list 1 2 3)")).to eq([1, 2, 3])
    expect(interpreter.eval("(define a 3) (list 1 2 a)")).to eq([1, 2, 3])
  end

  it "can set! a variable in a let expression" do
    expect(interpreter.eval("(let ((a 1)) (set! a 2) a)")).to eq(2)
  end

  it "can set! a variable in a nested let expression" do
    expect(interpreter.eval("(let ((a 1)) (let ((b 2)) (set! a 2)) a)")).to eq(2)
  end

  it "can define a variable" do
    expect(interpreter.eval("(define a 2) a")).to eq(2)
  end

  it "can define a function" do
    expect(interpreter.eval("(define (square x) (* x x)) (square 3)")).to eq(9)
  end

  it "handles recursion" do
    expect(
      interpreter.eval(
      "(define (fact n) (cond ((== n 0) 1) (else (* n (fact (- n 1))))))" \
      "(fact 6)"
    )).to eq(720)
  end

  it "supports user-defined macros" do
    expect(
      interpreter.eval(
      "(defmacro (my-let bindings body)" \
      "  (cons (list (quote lambda)" \
      "              (map (lambda (binding) (first binding))" \
      "                   bindings)" \
      "              body)" \
      "        (map (lambda (x) (first (rest x))) bindings)))" \
      "(my-let ((a 2) (b 3)) (+ a b))"
    )).to eq(5)
  end

  it "supports defining anaphoric macros" do
    expect(
      interpreter.eval(
      "(defmacro (aif condition consequent alternative)" \
      "  (list (quote let) (list (list (quote it) condition))" \
      "               (list (quote if) (quote it) consequent alternative)))" \
      "(define (square x) (* x x))" \
      "(aif (+ 1 2 3 4)" \
      "     (square it)" \
      "     0)" \
    )).to eq(100)
  end
end
