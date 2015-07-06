module Xdrgen::AST
  module Definitions
    class Union < Base
      extend Memoist
      include Concerns::Named
      include Concerns::Namespace
      include Concerns::Contained

      delegate :discriminant, to: :union_body
      delegate :name, to: :discriminant, prefix:true
      delegate :arms, to: :union_body
      delegate :normal_arms, to: :union_body
      delegate :default_arm, to: :union_body

      memoize def discriminant_type
        root.find_definition discriminant.type.name
      end

      def nested_definitions
        arms.
          map(&:declaration).
          reject{|d| d.is_a?(Declarations::Void)}.
          map(&:type).
          select{|d| d.is_a?(Concerns::NestedDefinition)}
      end
    end
  end
end
