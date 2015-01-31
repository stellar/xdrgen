module XdrTypedefGrammar

  class TypedefDef < Treetop::Runtime::SyntaxNode
    include XdrMainGrammar::Definition
    delegate :name, to: :declaration
  end
  
end