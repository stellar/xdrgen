module Xdrgen::AST
  class OctalConstant < Constant
    def value
      text_value.to_i(8)
    end
  end
end