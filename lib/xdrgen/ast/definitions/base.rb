module Xdrgen::AST::Definitions
  class Base < Treetop::Runtime::SyntaxNode
    attr_writer :ifdefs

    def ifdefs
      @ifdefs || []
    end

    def sub_type
      :simple
    end

  end
end