module Xdrgen::AST
  class VarSize < Treetop::Runtime::SyntaxNode
    def max_size
      raise NotImplementedError
    end
  end
end