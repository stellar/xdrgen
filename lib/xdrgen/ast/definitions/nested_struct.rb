module Xdrgen::AST
  module Definitions
    class NestedStruct < Struct
      include Concerns::NestedDefinition
    end
  end
end