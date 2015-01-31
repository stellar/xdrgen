module XdrNamespaceGrammar

  class NamespaceDef < Treetop::Runtime::SyntaxNode
    include XdrMainGrammar::Definition
    delegate :name, to: :identifier

    def definitions
      children.elements.select{|c| c.is_a?(Definition)}
    end
  end
  
end