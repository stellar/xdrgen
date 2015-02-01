module Xdrgen::AST
  module Definitions
    class StructBody < Base
      include Concerns::HasChildren

      def members
        children.select{|c| c.is_a?(StructMember)}
      end
    end
  end
end