module XdrMainGrammar
  module Definition ; end
  module Declaration ; end

  class NamespaceDef < Treetop::Runtime::SyntaxNode
    include Definition
    delegate :name, to: :identifier

    def definitions
      children.elements.select{|c| c.is_a?(Definition)}
    end
  end

  class TypedefDef < Treetop::Runtime::SyntaxNode
    include Definition
    delegate :name, to: :declaration
  end

end