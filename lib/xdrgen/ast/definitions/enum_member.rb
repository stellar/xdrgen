module Xdrgen::AST
  module Definitions
    class EnumMember < Base
      extend Memoist

      include Concerns::Named
      include Concerns::Contained

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
        value_n.constant.value
      end
    end
  end
end