module Xdrgen::AST
  module Definitions
    class Typedef < Base
      include Concerns::Contained
      delegate :name, to: :declaration
      delegate :type, to: :declaration
      delegate :sub_type, to: :type


    end
  end
end