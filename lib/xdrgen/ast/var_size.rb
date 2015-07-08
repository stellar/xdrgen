module Xdrgen::AST
  class VarSize < Treetop::Runtime::SyntaxNode
    def size
      return nil if size_t.text_value.blank?
      size_t.text_value
    end

    def named?
      size_t.is_a?(Xdrgen::AST::Identifier)
    end
  end
end
