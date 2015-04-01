module Xdrgen::AST
  class HexadecimalConstant < Constant
    def value
      text_value
    end
  end
end