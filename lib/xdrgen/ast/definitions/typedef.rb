module Xdrgen::AST
  module Definitions
    class Typedef < Base
      delegate :name, to: :declaration
    end
  end
end