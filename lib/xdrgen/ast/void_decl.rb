module Xdrgen::AST
  class VoidDecl < Declaration
    def type
      "void"
    end
  end
end