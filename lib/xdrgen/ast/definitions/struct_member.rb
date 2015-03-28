module Xdrgen::AST
  module Definitions
    class StructMember < Base
      delegate :name, to: :declaration
      delegate :type, to: :declaration

      def optional?
        declaration.is_a?(Declarations::Optional)
      end
    end
  end
end