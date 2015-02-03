module Xdrgen::AST
  module Definitions
    class Struct < Base
      include Concerns::Named
      include Concerns::Namespace
      include Concerns::Contained

      delegate :members, to: :struct_body

      def nested_definitions
        members.
          map(&:declaration).
          map(&:type).
          select{|d| d.is_a?(Concerns::NestedDefinition)}
      end
    end
  end
end