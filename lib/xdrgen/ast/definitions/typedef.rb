module Xdrgen::AST::Definitions
  class Typedef < Base
    delegate :name, to: :declaration
  end
end