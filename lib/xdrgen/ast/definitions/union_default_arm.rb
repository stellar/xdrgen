module Xdrgen::AST
  module Definitions
    class UnionDefaultArm < Base
      extend Memoist
      include Concerns::Contained
      
      delegate :name, to: :declaration
      delegate :type, to: :declaration

      memoize def union
        find_ancestors(Union).last
      end

      def void?
        declaration.is_a?(Declarations::Void)
      end
    end
  end
end