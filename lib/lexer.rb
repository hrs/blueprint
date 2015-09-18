module Blueprint
  class Lexer
    def initialize(input)
      @input = input
    end

    def tokenize
      @tokens = []
      @current_token = ""

      input.chars.each do |char|
        if char == "\s"
          finish_token
        elsif char == "(" || char == ")"
          finish_token
          @tokens << char
        elsif char =~ /[\w*+-\/\$\#]/
          @current_token += char
        else
          raise "unknown character \"#{char}\""
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
