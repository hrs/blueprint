require "spec_helper"

describe Blueprint::Frame do
  def frame
    @_frame ||= described_class.new
  end

  def child
    @_child ||= described_class.new(frame)
  end

  describe "#lookup" do
    it "returns the variable if one exists" do
      frame.define(:variable_name, :expected_value)

      expect(frame.lookup(:variable_name)).to eq(:expected_value)
    end

    it "searches up the stack to find a symbol" do
      frame.define(:variable_name, :expected_value)

      expect(child.lookup(:variable_name)).to eq(:expected_value)
    end

    it "raises an error if no variable can be found" do
      expect { frame.lookup(:variable_name) }.to raise_error(StandardError)
    end
  end

  describe "#defined?" do
    it "returns true when a symbol is bound" do
      frame.define(:variable_name, :expected_value)

      expect(frame.defined?(:variable_name)).to eq(true)
    end

    it "walks up the stack to find a variable" do
      frame.define(:variable_name, :expected_value)

      expect(child.defined?(:variable_name)).to eq(true)
    end

    it "returns false when a symbol is unbound" do
      expect(frame.defined?(:variable_name)).to eq(false)
    end
  end

  describe "#set!" do
    it "walks up the stack for a bound variable and sets it" do
      frame.define(:variable_name, :expected_value)

      child.set!(:variable_name, :set_value)

      expect(frame.lookup(:variable_name)).to eq(:set_value)
    end

    it "raises an error if it can't find that variable" do
      expect {
        frame.set!(:variable_name, :set_value)
      }.to raise_error(StandardError)
    end
  end

  describe "#push_with_bindings" do
    it "returns a child with the specified bindings" do
      frame.define(:variable_name, :old_value)

      child = frame.push_with_bindings(variable_name: :new_value)

      expect(child.lookup(:variable_name)).to eq(:new_value)
      expect(frame.lookup(:variable_name)).to eq(:old_value)
    end
  end

  context "when in a new stack frame" do
    it "creates new bindings existing only in the frame" do
      child.define(:variable_name, 42)
      expect(child.lookup(:variable_name)).to eq(42)

      expect { frame.lookup(:variable_name) }.to raise_error(StandardError)
    end

    it "nondestructively shadows existing symbols" do
      frame.define(:variable_name, :old_value)
      expect(frame.lookup(:variable_name)).to eq(:old_value)

      child.define(:variable_name, :new_value)
      expect(child.lookup(:variable_name)).to eq(:new_value)

      expect(frame.lookup(:variable_name)).to eq(:old_value)
    end
  end
end
