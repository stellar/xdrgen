module Xdrgen::AST
  class VarSize < Treetop::Runtime::SyntaxNode
    def size
      return nil if size_t.text_value.blank?
      size_t.text_value.to_i
    end
  end
end