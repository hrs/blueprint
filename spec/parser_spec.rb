require "spec_helper"

describe Blueprint::Parser do
  describe "#parse" do
    def expect_parsed_value_of(expression)
      expect(Blueprint::Parser.new(expression).parse)
    end

    it "handle integers" do
      expect_parsed_value_of("123").to eq([123])
    end

    it "handle floats" do
      expect_parsed_value_of("-0.123").to eq([-0.123])
    end

    it "handle symbols" do
      expect_parsed_value_of("abc").to eq([:abc])
    end

    it "handle strings" do
      expect_parsed_value_of("\"abc\"").to eq(["abc"])
    end

    it "escapes string characters" do
      expect_parsed_value_of("\"a\\bc\"").to eq(["a\\bc"])
    end

    it "handle math sigils in symbols" do
      expect_parsed_value_of("*").to eq([:*])
    end

    it "handles ? in symbol names" do
      expect_parsed_value_of("null?").to eq([:null?])
    end

    it "handles ! in symbol names" do
      expect_parsed_value_of("set!").to eq([:set!])
    end

    it "handles booleans" do
      expect_parsed_value_of("true").to eq([true])
      expect_parsed_value_of("false").to eq([false])
    end

    it "handles empty lists" do
      expect_parsed_value_of("()").to eq([[]])
      expect_parsed_value_of("( )").to eq([[]])
    end

    it "has a shortcut for quoting" do
      expect_parsed_value_of("'()").to eq([[:quote, []]])
      expect_parsed_value_of("'(a b c)").to eq([[:quote, [:a, :b, :c]]])
    end

    it "parses the quasiquote/unquote/unquote-splicing symbols" do
      expect_parsed_value_of("`4").to eq([[:quasiquote, 4]])
      expect_parsed_value_of(",4").to eq([[:unquote, 4]])
      expect_parsed_value_of(",@4").to eq([[:"unquote-splicing", 4]])
    end

    it "handle simple s-expressions" do
      expect_parsed_value_of("(+ 1 2)").to eq([[:+, 1, 2]])
    end

    it "handle nested s-expressions" do
      expect_parsed_value_of("(+ (- 4 3) 2)").to eq([[:+, [:-, 4, 3], 2]])
    end

    it "handles conditionals" do
      expect_parsed_value_of("(cond ((== 1 2) 3) (else 4))").
        to eq([[:cond, [[:==, 1, 2], 3], [:else, 4]]])
    end

    it "handles variadic arguments" do
      expect_parsed_value_of("(1 2 3 4 . 5)").to eq([[1, 2, 3, 4, :".", 5]])
    end
  end
end
