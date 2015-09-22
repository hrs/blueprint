require "spec_helper"

describe Blueprint::Parser do
  describe "#parse" do
    it "handle integers" do
      parser = Blueprint::Parser.new("123")
      expect(parser.parse).to eq([123])
    end

    it "handle floats" do
      parser = Blueprint::Parser.new("-0.123")
      expect(parser.parse).to eq([-0.123])
    end

    it "handle symbols" do
      parser = Blueprint::Parser.new("abc")
      expect(parser.parse).to eq([:abc])
    end

    it "handle strings" do
      parser = Blueprint::Parser.new("\"abc\"")
      expect(parser.parse).to eq(["abc"])
    end

    it "escapes string characters" do
      parser = Blueprint::Parser.new("\"a\\bc\"")
      expect(parser.parse).to eq(["a\\bc"])
    end

    it "handle math sigils in symbols" do
      parser = Blueprint::Parser.new("*")
      expect(parser.parse).to eq([:*])
    end

    it "handles ? in symbol names" do
      parser = Blueprint::Parser.new("null?")
      expect(parser.parse).to eq([:null?])
    end

    it "handles ! in symbol names" do
      parser = Blueprint::Parser.new("set!")
      expect(parser.parse).to eq([:set!])
    end

    it "handles empty lists" do
      parser = Blueprint::Parser.new("()")
      expect(parser.parse).to eq([[]])

      parser = Blueprint::Parser.new("( )")
      expect(parser.parse).to eq([[]])
    end

    it "has a shortcut for quoting" do
      parser = Blueprint::Parser.new("'()")
      expect(parser.parse).to eq([[:quote, []]])

      parser = Blueprint::Parser.new("'(a b c)")
      expect(parser.parse).to eq([[:quote, [:a, :b, :c]]])
    end

    it "handle simple s-expressions" do
      parser = Blueprint::Parser.new("(+ 1 2)")
      expect(parser.parse).to eq([[:+, 1, 2]])
    end

    it "handle nested s-expressions" do
      parser = Blueprint::Parser.new("(+ (- 4 3) 2)")
      expect(parser.parse).to eq([[:+, [:-, 4, 3], 2]])
    end

    it "handles conditionals" do
      parser = Blueprint::Parser.new("(cond ((== 1 2) 3) (else 4))")
      expect(parser.parse).to eq([[:cond, [[:==, 1, 2], 3], [:else, 4]]])
    end
  end
end
