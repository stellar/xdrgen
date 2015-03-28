module Xdrgen::AST
  module Definitions
    class UnionArm < Base
      extend Memoist
      include Concerns::Contained

      delegate :name, to: :declaration
      delegate :type, to: :declaration

      memoize def union
        find_ancestors(Union).last
      end

      def cases
        cases_n.elements.map{|c| c.value.text_value}
      end

      def void?
        declaration.is_a?(Declarations::Void)
      end
    end
  end
end