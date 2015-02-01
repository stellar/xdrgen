module Xdrgen::AST
  module Definitions
    class UnionDefaultArm < Base
      delegate :name, to: :declaration
    end
  end
end