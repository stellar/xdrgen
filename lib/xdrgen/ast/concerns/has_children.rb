module Xdrgen::AST
  module Concerns
    module HasChildren      
      def children
        children_n.elements
      end
    end
  end
end