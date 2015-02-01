module Xdrgen::AST::Typespecs
  class Opaque < Base
    def size
      raise NotImplementedError
    end
  end
end