module Xdrgen::AST
  class NamespaceDef < Definition
    delegate :name, to: :identifier

    def definitions
      children.elements.select{|c| c.is_a?(Definition)}
    end
  end
end