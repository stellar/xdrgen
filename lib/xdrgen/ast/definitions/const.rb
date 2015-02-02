module Xdrgen::AST
  module Definitions
    class Const < Base
      include Concerns::Named
      include Concerns::Contained

      def value
        value_n.text_value
      end
    end
  end
end