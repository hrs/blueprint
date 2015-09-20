require "spec_helper"

describe Blueprint::Environment do
  def environment
    @_environment ||= described_class.new
  end

  describe "#[]" do
    it "returns the variable if one exists" do
      environment[:variable_name] = :expected_value

      expect(environment[:variable_name]).to eq(:expected_value)
    end

    it "searches up the stack to find a symbol" do
      environment[:variable_name] = :expected_value
      environment.push_frame

      expect(environment[:variable_name]).to eq(:expected_value)
    end

    it "raises an error if no variable can be found" do
      expect { environment[:variable_name] }.to raise_error(StandardError)
    end
  end

  describe "#defined?" do
    it "returns true when a symbol is bound" do
      environment[:variable_name] = :expected_value

      expect(environment.defined?(:variable_name)).to eq(true)
    end

    it "walks up the stack to find a variable" do
      environment[:variable_name] = :expected_value
      environment.push_frame

      expect(environment.defined?(:variable_name)).to eq(true)
    end

    it "returns false when a symbol is unbound" do
      expect(environment.defined?(:variable_name)).to eq(false)
    end
  end

  describe "#set!" do
    it "walks up the stack for a bound variable and sets it" do
      environment[:variable_name] = :expected_value
      environment.push_frame

      environment.set!(:variable_name, :set_value)
      environment.pop_frame

      expect(environment[:variable_name]).to eq(:set_value)
    end

    it "raises an error if it can't find that variable" do
      expect {
        environment.set!(:variable_name, :set_value)
      }.to raise_error(StandardError)
    end
  end

  context "when in a new stack frame" do
    it "creates new bindings existing only in the frame" do
      environment.push_frame
      environment[:variable_name] = 42
      expect(environment[:variable_name]).to eq(42)

      environment.pop_frame
      expect { environment[:variable_name] }.to raise_error(StandardError)
    end

    it "nondestructively shadows existing symbols" do
      environment[:variable_name] = :old_value
      expect(environment[:variable_name]).to eq(:old_value)

      environment.push_frame
      environment[:variable_name] = :new_value
      expect(environment[:variable_name]).to eq(:new_value)

      environment.pop_frame
      expect(environment[:variable_name]).to eq(:old_value)
    end
  end

  it "raises an error when trying to pop the global frame" do
    expect { environment.pop_frame }.to raise_error(StandardError)
  end
end
