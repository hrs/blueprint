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
end
