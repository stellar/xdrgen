module Xdrgen::AST
  class HexadecimalConstant < Constant
    def value
      text_value.to_i(16)
    end
  end
end