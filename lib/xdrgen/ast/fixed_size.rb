module Xdrgen::AST
  class FixedSize < Treetop::Runtime::SyntaxNode
    def size
      size_t.text_value.to_i
    end
  end
end