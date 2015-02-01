module Xdrgen::AST
  module Definitions
    class Struct < Base
      include Concerns::Named
      delegate :members, to: :struct_body
    end
  end
end