module Xdrgen::AST::Typespecs
  class String < Treetop::Runtime::SyntaxNode
    include Base
    
    delegate :size, to: :decl
    delegate :name, to: :decl
    delegate :fixed?, to: :decl

  end
end
