module Xdrgen::AST
  class EnumDef < Definition
    delegate :name, to: :identifier
  end
end