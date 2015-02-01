module Xdrgen::AST
  class TypedefDef < Definition
    delegate :name, to: :declaration
  end
end