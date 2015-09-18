module Blueprint
  class Parser
    def parse(tokens)
      if tokens.is_a?(Array)
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
              ast << parse(sub_expression)
              sub_expression = []
            else
              sub_expression << token
            end
          elsif depth == 0
            ast << parse(token)
          else
            sub_expression << token
          end
        end

        if !sub_expression.empty?
          ast << parse(sub_expression)
        end

        ast
      elsif tokens.to_i.to_s == tokens
        tokens.to_i
      else
        tokens.to_sym
      end
    end
  end
end
