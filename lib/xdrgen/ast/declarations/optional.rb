module Xdrgen::AST::Declarations
  class Optional < Base
    delegate :name, to: :identifier
  end
end