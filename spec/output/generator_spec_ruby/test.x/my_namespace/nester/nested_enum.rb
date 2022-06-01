# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum {
#       BLAH_1,
#       BLAH_2
#     }
#
# ===========================================================================
module MyNamespace
  class Nester
    class NestedEnum < XDR::Enum
      member :blah_1, 0
      member :blah_2, 1

      seal
    end
  end
end
