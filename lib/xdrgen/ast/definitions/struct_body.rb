module Xdrgen::AST
  module Definitions
    class StructBody < Base
      def members
        members_n.elements.select{|c| c.is_a?(StructMember)}
      end
    end
  end
end