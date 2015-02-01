module Xdrgen::AST::Concerns
  module Named
    delegate :name, to: :identifier
  end
end