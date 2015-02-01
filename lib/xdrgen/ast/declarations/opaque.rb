module Xdrgen::AST::Declarations
  class Opaque < Base
    delegate :name, to: :identifier

    def size
      size_spec.size
    end

    def fixed?
      size_spec.is_a?(Xdrgen::AST::FixedSize)
    end
  end
end