module Xdrgen::AST
  module Concerns
    module Named
      delegate :name, to: :identifier

      def namespaces
        return [] unless self.is_a?(Contained)
        self.find_ancestors(Concerns::Namespace)
      end

      def fully_qualified_name
        namespaces.map(&:name) + [name]
      end

      def find_common_prefix(names)
        names_words = names.map { |n| n.split("_") }
        i = 0
        loop do
          word = names_words[0][i]
          break if word.nil?
          break unless names_words.all? { |n| word == n[i] }
          i += 1
        end
        prefix = names_words[0][0...i].join("_") + "_"
        return "" if names.any? { |n| prefix.length >= n.length}
        prefix
      end
    end
  end
end