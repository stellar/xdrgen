module Xdrgen::AST
  module Definitions
    class StructMember < Base
      delegate :name, to: :declaration
      delegate :type, to: :declaration

    end
  end
end