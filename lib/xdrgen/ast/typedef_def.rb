module Xdrgen::AST
  class TypedefDef < Definition
    delegate :name, to: :identifier

    def type
      raise NotImplementedError
    end
  end
end