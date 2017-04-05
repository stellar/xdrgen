module Xdrgen::AST::Declarations
  class Opaque < Base
    delegate :name, to: :identifier
    delegate :size, to: :size_spec
    delegate :resolved_size, to: :size_spec

    def fixed?
      size_spec.is_a?(Xdrgen::AST::FixedSize)
    end
  end
end