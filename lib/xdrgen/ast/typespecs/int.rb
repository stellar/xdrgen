module Xdrgen::AST::Typespecs
  class Int < Base

    def unsigned?
      unsigned.text_value.present?
    end

    def size
      size_t.text_value.to_sym
    end
  end
end