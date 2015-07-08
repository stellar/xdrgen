module Xdrgen::AST
  class FixedSize < Treetop::Runtime::SyntaxNode
    def size
      size_t.text_value
    end

    def named?
      size_t.is_a?(Xdrgen::AST::Identifier)
    end
  end
end
