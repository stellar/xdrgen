module Xdrgen::AST
  module Definitions
    class Namespace < Base
      include Concerns::Named
      include Concerns::Namespace
      include Concerns::HasDefinitions
    end
  end
end