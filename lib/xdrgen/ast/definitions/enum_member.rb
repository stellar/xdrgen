module Xdrgen::AST
  module Definitions
    class EnumMember < Base
      include Concerns::Named
      include Concerns::Contained

      def value
        1
      end
    end
  end
end