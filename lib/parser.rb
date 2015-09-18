module Blueprint
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def parse
      if tokens.is_a?(Array)
        parse_array
      elsif tokens.chars.all? { |char| char =~ /\d/ }
        parse_integer
      else
        parse_symbol
      end
    end

    private

    def parse_array
      ast = []
      depth = 0
      sub_expression = []

      tokens.each do |token|
        if token == "("
          if depth != 0
            sub_expression << token
          end
          depth += 1
        elsif token == ")"
          depth -= 1
          if depth == 0
            ast << self.class.new(sub_expression).parse
            sub_expression = []
          else
            sub_expression << token
          end
        elsif depth == 0
          ast << self.class.new(token).parse
        else
          sub_expression << token
        end
      end

      if !sub_expression.empty?
        ast << self.class.new(sub_expression).parse
      end

      ast
    end

    def parse_integer
      tokens.to_i
    end

    def parse_symbol
      tokens.to_sym
    end

    attr_reader :tokens
  end
end
