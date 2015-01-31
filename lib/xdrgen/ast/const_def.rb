module Xdrgen::AST
  class ConstDef < Definition
    
    delegate :name, to: :identifier
    delegate :value, to: :constant
  end
end