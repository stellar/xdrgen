module Xdrgen::AST
  module Definitions
    class EnumMember < Base
      extend Memoist

      include Concerns::Named
      include Concerns::Contained

      def name_short
        prefix = find_common_prefix(enum.members.map(&:name))
        short = name.delete_prefix(prefix)
        # Prefix the name with the first letter of the prefix if the name begins
        # with a number, since in most languages identifiers cannot begin with
        # numbers.
        short = "#{prefix.first}#{short}" if /\A\d+/ === short
        short
      end

      def value
        unsigned_value = defined_value || auto_value

        # enums are signed in xdr, so...
        # convert to twos complement value
        [unsigned_value].pack("l>").unpack("l>").first
      end

      memoize def enum
        find_ancestors(Enum).last
      end


      def auto_value
        index = enum.members.index(self)
        if index == 0
          0
        else
          # use the previous members value + 1
          enum.members[index - 1].value + 1
        end
      end

      def defined_value
        return if value_n.terminal?

        case value_n.val
        when Constant
          value_n.val.value
        when Identifier
          namespace.find_enum_value(value_n.val.name).defined_value
        end
      end
    end
  end
end
