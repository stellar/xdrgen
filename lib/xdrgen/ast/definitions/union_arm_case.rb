module Xdrgen::AST
  module Definitions
    class UnionArmCase < Base

      def value_s
        value.text_value
      end
      
    end
  end
end
