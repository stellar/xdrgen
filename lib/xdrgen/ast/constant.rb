module Xdrgen::AST
  class Constant < Treetop::Runtime::SyntaxNode
    def value
      raise NotImplementedError, "implement in subclass"
    end
  end
end