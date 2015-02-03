module Xdrgen::AST
  module Definitions
    class Union < Base
      include Concerns::Named
      include Concerns::Namespace
      include Concerns::Contained
      
      delegate :discriminant, to: :union_body
      delegate :name, to: :discriminant, prefix:true
      delegate :arms, to: :union_body

      def discriminant_type
        discriminant.type.name
      end
    end
  end
end