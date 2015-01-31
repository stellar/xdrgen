module Xdrgen::AST
  class Declaration < Treetop::Runtime::SyntaxNode

    delegate :name, to: :identifier

  end
end