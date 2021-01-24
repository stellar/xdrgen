module Xdrgen::AST
  module Definitions
    class Union < Base
      extend Memoist
      include Concerns::Named
      include Concerns::Namespace
      include Concerns::Contained

      delegate :discriminant, to: :union_body
      delegate :name, to: :discriminant, prefix:true
      delegate :arms, to: :union_body
      delegate :normal_arms, to: :union_body
      delegate :default_arm, to: :union_body

      memoize def discriminant_type
        return nil unless discriminant.type.is_a?(Identifier)

        root.find_definition discriminant.type.name
      end

      def resolved_case(kase)
        if discriminant_type.nil? then
          # discriminant_type has not been found we need to search for the value in namespace's enum constants.
          # It's a case where union discriminant is a standard type (like `int`):
          #
          # enum StellarValueType
          # {
          #     STELLAR_VALUE_BASIC = 0,
          #     STELLAR_VALUE_SIGNED = 1
          # };
          #
          # union switch (int v)
          # {
          # case STELLAR_VALUE_BASIC:
          #     void;
          #     ...
          found = namespace.find_enum_value(kase.value_s)
          raise "Case error:  #{kase} (#{kase.value_s}) constant not found" if found.nil?
        else
          found = discriminant_type.members.find{|m| m.name == kase.value_s}
          raise "Case error:  #{kase} is not a member of #{discriminant_type.name}" if found.nil?
        end
        found
      end

      def nested_definitions
        arms.
          map(&:declaration).
          reject{|d| d.is_a?(Declarations::Void)}.
          map(&:type).
          select{|d| d.is_a?(Concerns::NestedDefinition)}
      end
    end
  end
end
