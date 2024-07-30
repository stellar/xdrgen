module Xdrgen::AST
  module Definitions
    class UnionArmCase < Base
      extend Memoist

      include Concerns::Named
      include Concerns::Contained

      def value_s
        value.text_value
      end

      memoize def union
        find_ancestors(Union).last
      end

      def name_short
        prefix = find_common_prefix(union.discriminant_type.members.map(&:name))
        short = value.name.delete_prefix(prefix)
        # Prefix the name with the first letter of the prefix if the name begins
        # with a number, since in most languages identifiers cannot begin with
        # numbers.
        short = "#{prefix.first}#{short}" if /\A\d+/ === short
        short
      end
    end
  end
end
