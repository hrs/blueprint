require "spec_helper"

describe Blueprint::Evaluator do
  describe "#eval" do
    def evaluator
      Blueprint::Evaluator.new
    end

    it "can evaluate a simple mathematical expression" do
      expect(evaluator.eval([:+, 3, 4])).to eq(7)
    end

    it "can evaluate a conditional" do
      expect(evaluator.eval([:cond, [[:==, 3, 4], 2], [:else, 1]])).to eq(1)
    end

    it "can evaluate a lambda expression" do
      expect(evaluator.eval([[:lambda, [:x], [:+, :x, 4]], 3])).to eq(7)
    end

    it "can evaluate nested lambda expressions" do
      expect(
        evaluator.eval(
        [[[:lambda, [:x],
           [:lambda, [:y],
            [:+, :x, :y]]],
          3],
         4]
      )).to eq(7)
    end

    it "handles lambdas with more than one argument" do
      expect(
        evaluator.eval(
        [[:lambda, [:x, :y], [:+, :x, :y]], 3, 4]
      )).to eq(7)
    end
  end
end
