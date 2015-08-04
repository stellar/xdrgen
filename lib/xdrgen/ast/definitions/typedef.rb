module Xdrgen::AST
  module Definitions
    class Typedef < Base
      include Concerns::Contained
      delegate :name, to: :declaration
      delegate :type, to: :declaration
      delegate :sub_type, to: :type

      def resolved_type
        cur = self

        cur = root.find_definition(cur.type.text_value) while cur.is_a?(Typedef)

        cur
      end

    end
  end
end
