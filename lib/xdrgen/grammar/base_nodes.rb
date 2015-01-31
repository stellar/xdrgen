module XdrBaseGrammar

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

end