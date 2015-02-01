module Xdrgen::AST
  module Concerns
    module HasDefinitions
      include HasChildren
      
      def typedefs
        find_children(Definitions::Typedef)
      end  

      def consts
        find_children(Definitions::Const)
      end

      def structs
        find_children(Definitions::Struct)
      end

      def enums
        find_children(Definitions::Enum)
      end

      def unions
        find_children(Definitions::Union)
      end

      def namespaces
        find_children(Definitions::Namespace)
      end

      private
      def find_children(type)
        children.select{|c| c.is_a? type}
      end
    end
  end
end