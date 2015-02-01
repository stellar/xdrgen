module Xdrgen::AST::Declarations
  class Optional < Base
    delegate :name, to: :identifier

    def child_type
      type.text_value
    end
  end
end