module Xdrgen::AST::Declarations
  class String < Base
    delegate :name, to: :identifier

    def size
      size_spec.size
    end

    def fixed?
      size_spec.is_a?(Xdrgen::AST::VarSize)
    end
  end
end
