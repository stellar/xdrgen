module Xdrgen::AST
  module Definitions
    class NestedUnion < Union
      include Concerns::NestedDefinition
    end
  end
end