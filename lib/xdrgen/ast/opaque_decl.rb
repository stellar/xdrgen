module Xdrgen::AST
  class OpaqueDecl < Declaration
    def type
      "opaque"
    end
  end
end