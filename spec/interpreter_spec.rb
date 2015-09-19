require "spec_helper"

describe Blueprint::Interpreter do
  def interpreter
    described_class.new
  end

  it "handles basic arithmetic" do
    expect(interpreter.eval("(+ 1 2 3)")).to eq(6)
  end
end
