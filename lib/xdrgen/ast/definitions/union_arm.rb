module Xdrgen::AST
  module Definitions
    class UnionArm < Base
      delegate :name, to: :declaration

    end
  end
end