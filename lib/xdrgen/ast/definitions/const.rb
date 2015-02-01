module Xdrgen::AST
  module Definitions
    class Const < Base
      include Concerns::Named
      delegate :value, to: :constant
    end
  end
end