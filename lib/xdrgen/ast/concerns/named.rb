module Xdrgen::AST
  module Concerns
    module Named
      delegate :name, to: :identifier

      def fully_qualified_name
        return name unless self.is_a?(Contained)
        
        namespaces = self.find_ancestors(Definitions::Namespace)

        namespaces.map(&:name) + [name]
      end
    end
  end
end