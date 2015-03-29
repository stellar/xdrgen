module Xdrgen::AST::Definitions
  class Base < Treetop::Runtime::SyntaxNode

    def sub_type
      :simple
    end
    
  end
end