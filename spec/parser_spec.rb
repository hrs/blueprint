require "spec_helper"

describe Blueprint::Parser do
  describe "#parse" do
    it "should handle integers" do
      parser = Blueprint::Parser.new("123")
      expect(parser.parse).to eq([123])
    end

    it "should handle symbols" do
      parser = Blueprint::Parser.new("abc")
      expect(parser.parse).to eq([:abc])
    end

    it "should handle math sigils in symbols" do
      parser = Blueprint::Parser.new("*")
      expect(parser.parse).to eq([:*])
    end

    it "should handle simple s-expressions" do
      parser = Blueprint::Parser.new("(+ 1 2)")
      expect(parser.parse).to eq([[:+, 1, 2]])
    end

    it "should handle nested s-expressions" do
      parser = Blueprint::Parser.new("(+ (- 4 3) 2)")
      expect(parser.parse).to eq([[:+, [:-, 4, 3], 2]])
    end
  end
end
