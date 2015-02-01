module Xdrgen::AST
  class Top < Treetop::Runtime::SyntaxNode
    include Concerns::HasDefinitions

    attr_accessor :path
  end
end