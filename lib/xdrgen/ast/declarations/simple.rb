module Xdrgen::AST::Declarations
  class Simple < Base
    delegate :name, to: :identifier
    

  end
end