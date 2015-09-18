require "rspec/autorun"

module Blueprint
  class Lexer
    def initialize(input)
      @input = input
    end

    def tokenize
      @tokens = []
      @current_token = ""

      input.chars.each do |c|
        if c == " "
          finish_token
        elsif ["(", ")"].include?(c)
          finish_token
          @tokens << c
        elsif c =~ /[\w*+-\/\$\#]/
          @current_token += c
        end
      end
      finish_token

      @tokens
    end

    private

    def finish_token
      if @current_token != ""
        @tokens << @current_token
        @current_token = ""
      end
    end

    attr_reader :input # !> private attribute?
  end
end

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
