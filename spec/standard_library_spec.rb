require "spec_helper"

describe Blueprint::Interpreter do
  def interpreter
    described_class.new
  end

  describe "null?" do
    it "returns true when its argument is the empty list" do
      expect(interpreter.eval("(null? (quote ()))")).to eq(true)
    end

    it "returns false otherwise" do
      expect(interpreter.eval("(null? (quote (1 2)))")).to eq(false)
    end
  end

  describe "map" do
    it "maps a function across a list" do
      expect(
        interpreter.eval(
        "(map (lambda (n) (+ 1 n)) (quote (1 2 3)))"
      )).to eq([2, 3, 4])
    end

    it "returns an empty list when given one" do
      expect(
        interpreter.eval(
        "(map (lambda (n) (+ 1 n)) (quote ()))"
      )).to eq([])
    end
  end

  describe "let" do
    it "expands into an equivalent lambda expression" do
      expect(
        interpreter.eval(
        "(let ((x 3) (y 4)) (+ x y))"
      )).to eq(7)
    end
  end

  describe "if" do
    it "expands into the equivalent cond expression" do
      expect(
        interpreter.eval(
        "(if (== 1 2) 3 4)"
      )).to eq(4)
    end

    it "doesn't inadvertently execute the alternative branch" do
      expect(
        interpreter.eval(
        "(let ((a 3))" \
        "(if (== 1 2) (set! a 12) a))" \
      )).to eq(3)
    end
  end
end
