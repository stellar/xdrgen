module Xdrgen::AST
  module Concerns
    module NestedDefinition

      def name
        find_ancestors(Declarations::Base).last.name
      end
      
    end
  end
end