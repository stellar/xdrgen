module Xdrgen::AST
  module Declarations
    class Base < Treetop::Runtime::SyntaxNode
      TYPE_NODES = [
        Typespecs::Base,
        Concerns::NestedDefinition,
        Concerns::Contained,
      ]

      def type
        search(type_s) do |node|
          TYPE_NODES.any?{|t| node.is_a?(t)}
        end
      end

      private
      def search(cur_el, &predicate)
        return cur_el if predicate.call(cur_el)
        return if cur_el.elements.blank?

        cur_el.elements.each do |next_el|
          child_result = search(next_el, &predicate)
          return child_result if child_result.present?
        end
      end
    end
  end
end
