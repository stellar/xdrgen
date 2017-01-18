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

      def definitions
        find_children(Definitions::Base)
      end

      def find_definition(name)
        found = definitions.find{|d| d.name == name}
        return found if found

        namespaces.each do |ns|
          found = ns.find_definition(name)
          return found if found
        end

        nil
      end

      def find_enum_value(name)
        enums.each do |e|
          found = e.members.find{|d| d.name == name}
          return found if found
        end
        raise "Could not find enum value #{name}"
      end

      ##
      # Collapse the flat list of definitions in this 
      # container into a nested array, grouping the
      # definitions by contiguous types:
      # 
      # Example:
      # 
      # [Typedef, Typedef, Typedef, Const, Struct, Struct, Typedef]
      # 
      # becomes:
      # 
      # [[Typedef, Typedef, Typedef], [Const], [Struct, Struct], [Typedef]]
      # 
      # 
      def definition_blocks
        children.each_with_object([]) do |child, result|
          next unless child.is_a?(Definitions::Base)

          current_group = result.last
          
          if current_group.blank?
            result.push [child]
          elsif current_group.last.is_a?(child.class)
            current_group.push child
          else
            result.push [child]
          end
        end
      end

      private
      def find_children(type)
        children.select{|c| c.is_a? type}
      end
    end
  end
end