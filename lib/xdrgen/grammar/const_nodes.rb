module XdrConstGrammar

  class ConstDef < Treetop::Runtime::SyntaxNode
    include XdrMainGrammar::Definition
    delegate :name, to: :identifier
    delegate :value, to: :constant
  end
end