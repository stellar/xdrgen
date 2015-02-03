module Xdrgen::AST
  module Definitions
    class UnionBody < Base
      extend Memoist

      memoize def arms
        [
          cases_n.elements.select{|c| c.is_a?(UnionArm)},
          default_arm,
        ].flatten.compact
      end

      def default_arm
        default_case_n unless default_case_n.terminal?
      end
    end
  end
end