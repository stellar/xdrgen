module Xdrgen::AST::Typespecs
  class Float < Base
    def size
      size_t.text_value.to_sym
    end
  end
end