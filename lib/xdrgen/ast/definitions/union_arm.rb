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
        cases_n.elements
      end

      def resolved_case(kase)
        union.resolved_case kase
      end

      def resolved_cases
        enum = union.discriminant_type

        cases.map{|kase| resolved_case kase}
      end

      def void?
        declaration.is_a?(Declarations::Void)
      end
    end
  end
end
