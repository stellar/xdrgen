module Xdrgen::AST
  class Identifier < Treetop::Runtime::SyntaxNode
    alias_method :name, :text_value
  end
end