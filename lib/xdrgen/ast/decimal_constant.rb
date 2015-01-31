module Xdrgen::AST
  class DecimalConstant < Constant
    def value
      text_value.to_i
    end
  end
end