module Xdrgen::AST::Declarations
  class String < Base
    delegate :name, to: :identifier

    def size
      size_str = size_spec.size_t.text_value

      size_str.to_i if size_str.present?
    end
  end
end