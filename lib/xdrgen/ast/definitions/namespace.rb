module Xdrgen::AST::Definitions
  class Namespace < Base
    delegate :name, to: :identifier

    def definitions
      children.elements.select{|c| c.is_a?(Xdrgen::AST::Definitions::Base)}
    end
  end
end