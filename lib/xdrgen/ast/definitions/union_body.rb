module Xdrgen::AST
  module Definitions
    class UnionBody < Base
      include Concerns::HasChildren

      def arms
        children.select{|c| c.is_a?(UnionArm)}
      end
    end
  end
end