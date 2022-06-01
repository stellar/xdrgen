# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum UnionKey {
#     ONE = 1,
#     TWO = 2,
#     OFFER = 3
#   };
#
# ===========================================================================
class UnionKey < XDR::Enum
  member :one,   1
  member :two,   2
  member :offer, 3

  seal
end
