module Xdrgen::AST
  module Definitions
    class StructMember < Base
      delegate :name, to: :declaration

    end
  end
end