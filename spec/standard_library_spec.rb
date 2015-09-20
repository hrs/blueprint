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
end
