module Xdrgen::AST
  class FixedSize < Treetop::Runtime::SyntaxNode
    def size
      raise NotImplementedError
    end
  end
end