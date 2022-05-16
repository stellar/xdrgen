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
        # prefix = find_common_prefix(union.normal_arms.map(&:cases).flatten.map(&:value).map(&:name))
        prefix = find_common_prefix(union.discriminant_type.members.map(&:name))
        value.name.delete_prefix(prefix)
      end
    end
  end
end
