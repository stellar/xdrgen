module Xdrgen::AST
  class FixedSize < Treetop::Runtime::SyntaxNode
    def size
      size_t.text_value
    end
  end
end
