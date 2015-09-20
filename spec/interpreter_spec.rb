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
end
