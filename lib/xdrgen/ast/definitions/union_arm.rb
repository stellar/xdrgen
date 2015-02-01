module Xdrgen::AST
  module Definitions
    class UnionArm < Base
      delegate :name, to: :declaration

      def cases
        cases_n.elements.map{|c| c.value.text_value}
      end
    end
  end
end