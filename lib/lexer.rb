module Blueprint
  class Lexer
    def initialize(input)
      @input = input
    end

    def tokenize
      @tokens = []
      @current_token = ""

      input.chars.each do |c|
        if c == "\s"
          finish_token
        elsif c == "(" || c == ")"
          finish_token
          @tokens << c
        elsif c =~ /[\w*+-\/\$\#]/
          @current_token += c
        else
          raise "unknown character \"#{c}\""
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

    attr_reader :input
  end
end
