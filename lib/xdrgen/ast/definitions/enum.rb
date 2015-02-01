module Xdrgen::AST::Definitions
  class Enum < Base
    delegate :name, to: :identifier
  end
end