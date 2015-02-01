module Xdrgen::AST
  module Definitions
    class StructMember < Base
      delegate :name, to: :identifier

    end
  end
end