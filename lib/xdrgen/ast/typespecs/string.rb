module Xdrgen::AST::Typespecs
  class String < Base
    def max_size
      raise NotImplementedError
    end
  end
end