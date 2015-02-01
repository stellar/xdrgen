module Xdrgen::AST::Definitions
  class Struct < Base
    delegate :name, to: :identifier
  end
end