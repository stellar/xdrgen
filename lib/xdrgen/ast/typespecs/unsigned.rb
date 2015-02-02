module Xdrgen::AST::Typespecs
  class Unsigned < Int

    def unsigned?
      true
    end

    def size
      :int
    end
  end
end