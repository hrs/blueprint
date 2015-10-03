module Blueprint
  class SpecialForm
    def initialize(&block)
      @behavior = block
    end

    def call(expression, frame)
      behavior.call(expression, frame)
    end

    private

    attr_reader :behavior
  end
end
