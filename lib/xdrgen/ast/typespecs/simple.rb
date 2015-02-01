module Xdrgen::AST::Typespecs
  class Simple < Base
    def child_type
      raise NotImplementedError
    end
  end
end