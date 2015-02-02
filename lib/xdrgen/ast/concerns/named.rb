module Xdrgen::AST
  module Concerns
    module Named
      delegate :name, to: :identifier

      def namespaces
        return [] unless self.is_a?(Contained)
        self.find_ancestors(Definitions::Namespace)
      end

      def fully_qualified_name
        namespaces.map(&:name) + [name]
      end
    end
  end
end