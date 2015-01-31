module XdrGrammar
  module Definition ; end
  module Declaration ; end

  class NamespaceDef < Treetop::Runtime::SyntaxNode
    include Definition
    delegate :name, to: :identifier

    def definitions
      children.elements.select{|c| c.is_a?(Definition)}
    end
  end  

  class ConstDef < Treetop::Runtime::SyntaxNode
    include Definition
    delegate :name, to: :identifier
    delegate :value, to: :constant
  end

  class TypedefDef < Treetop::Runtime::SyntaxNode
    include Definition
    delegate :name, to: :declaration
  end


  class DecimalConstant < Treetop::Runtime::SyntaxNode
    def value
      text_value.to_i
    end
  end

  class HexidecimalConstant < Treetop::Runtime::SyntaxNode
    def value
      text_value.to_i(16)
    end
  end

  class OctalConstant < Treetop::Runtime::SyntaxNode
    def value
      text_value.to_i(8)
    end
  end

  class Identifier < Treetop::Runtime::SyntaxNode
    alias_method :name, :text_value
  end

  class Enum < Treetop::Runtime::SyntaxNode ; end
  class EnumMember < Treetop::Runtime::SyntaxNode ; end

end