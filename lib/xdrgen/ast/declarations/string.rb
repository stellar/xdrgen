module Xdrgen::AST::Declarations
  class String < Base
    delegate :name, to: :identifier
    delegate :size, to: :size_spec
    delegate :resolved_size, to: :size_spec
  end
end
