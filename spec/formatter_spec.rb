require "spec_helper"

describe Blueprint::Formatter do
  describe "#format" do
    def expect_formatting_for(expression)
      expect(Blueprint::Formatter.new(expression).format)
    end

    it "formats literals" do
      expect_formatting_for(5).to eq("5")
      expect_formatting_for(5.0).to eq("5.0")
      expect_formatting_for(:foo).to eq("foo")
    end

    it "can quote strings, or not" do
      expect(Blueprint::Formatter.new("foo").format).to eq("foo")
      expect(Blueprint::Formatter.new("foo", quote_strings: true).format).
        to eq("\"foo\"")
    end

    it "formats lists" do
      expect_formatting_for([]).to eq("()")
      expect_formatting_for([1, [2, 3], 4]).to eq("(1 (2 3) 4)")
      expect(
        Blueprint::Formatter.new([1, :foo, "foo"], quote_strings: true).format
      ).to eq("(1 foo \"foo\")")
    end

    it "handles quotes" do
      expect_formatting_for([:quote, :symbol]).to eq("'symbol")
      expect_formatting_for([:quote, [1, 2]]).to eq("'(1 2)")
    end

    it "handles quasiquotes, commas, and splicing" do
      expect_formatting_for([:quasiquote, :symbol]).to eq("`symbol")
      expect_formatting_for([:quasiquote, [1, 2]]).to eq("`(1 2)")
      expect_formatting_for([:unquote, :symbol]).to eq(",symbol")
      expect_formatting_for([:unquote, [1, 2]]).to eq(",(1 2)")
      expect_formatting_for([:"unquote-splicing", :symbol]).to eq(",@symbol")
      expect_formatting_for([:"unquote-splicing", [1, 2]]).to eq(",@(1 2)")
    end

    it "formats closures" do
      expect_formatting_for(
        Blueprint::Closure.new([:a, :b], [], nil)
      ).to eq("#<lambda (a b)>")
    end

    it "formats macros" do
      expect_formatting_for(
        Blueprint::Macro.new([:a, :b], [])
      ).to eq("#<macro (a b)>")
    end
  end
end
