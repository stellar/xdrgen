module Xdrgen::AST
  module Concerns
    module NestedDefinition

      def name
        find_ancestors(Declarations::Base).last.name
      end

      def parent_defn
        find_ancestors(Definitions::Struct).last ||
        find_ancestors(Definitions::Union).last
      end
      
    end
  end
end