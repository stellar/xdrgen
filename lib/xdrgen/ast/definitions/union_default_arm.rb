module Xdrgen::AST
  module Definitions
    class UnionDefaultArm < Base
      delegate :name, to: :declaration

      def void?
        declaration.is_a?(Declarations::Void)
      end
    end
  end
end