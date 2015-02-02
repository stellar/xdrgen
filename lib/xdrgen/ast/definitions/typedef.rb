module Xdrgen::AST
  module Definitions
    class Typedef < Base
      include Concerns::Contained
      delegate :name, to: :declaration

    end
  end
end