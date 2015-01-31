module XdrStructGrammar

  class StructDef < Treetop::Runtime::SyntaxNode
    include XdrMainGrammar::Definition
    delegate :name, to: :identifier
  end
end