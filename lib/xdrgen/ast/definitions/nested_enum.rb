module Xdrgen::AST
  module Definitions
    class NestedEnum < Enum
      include Concerns::NestedDefinition
    end
  end
end