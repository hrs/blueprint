require "rspec/autorun"
require_relative "blueprint"

describe Blueprint::Lexer do
  describe "#tokenize" do
    it "parses a single integer" do
      lexer = Blueprint::Lexer.new("123")
      expect(lexer.tokenize).to eq(["123"])
    end

    it "parses a single symbol" do
      lexer = Blueprint::Lexer.new("abc")
      expect(lexer.tokenize).to eq(["abc"])
    end

    it "parses mathematical characters in symbols" do
      lexer = Blueprint::Lexer.new("a*8c/#")
      expect(lexer.tokenize).to eq(["a*8c/#"])
    end

    it "parses parens" do
      lexer = Blueprint::Lexer.new("(+ 1 2)")
      expect(lexer.tokenize).to eq(["(", "+", "1", "2", ")"])
    end
  end
end

describe Blueprint::Parser do
  describe "#parse" do
    def parser
      Blueprint::Parser.new
    end

    it "should handle integers" do
      expect(parser.parse(["123"])).to eq([123])
    end

    it "should handle symbols" do
      expect(parser.parse(["abc"])).to eq([:abc])
    end

    it "should handle simple s-expressions" do
      expect(parser.parse(["(", "+", "1", "2", ")"])).
        to eq([[:+, 1, 2]])
    end

    it "should handle nested s-expressions" do
      expect(parser.parse(["(", "+", "(", "-", "4", "3", ")", "2", ")"])).
        to eq([[:+, [:-, 4, 3], 2]])
    end
  end
end

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
