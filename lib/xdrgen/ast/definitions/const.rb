module Xdrgen::AST::Definitions
  class Const < Base
    
    delegate :name, to: :identifier
    delegate :value, to: :constant
  end
end