require "spec_helper"

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

    it "parses parentheses" do
      lexer = Blueprint::Lexer.new("(+ 1 2)")
      expect(lexer.tokenize).to eq(["(", "+", "1", "2", ")"])
    end
  end
end
