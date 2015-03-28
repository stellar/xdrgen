module Xdrgen::AST
  module Definitions
    class UnionArm < Base
      delegate :name, to: :declaration
      delegate :type, to: :declaration

      def cases
        cases_n.elements.map{|c| c.value.text_value}
      end

      def void?
        declaration.is_a?(Declarations::Void)
      end
    end
  end
end