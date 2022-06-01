# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum UnionKey {
#     ERROR,
#     MULTI
#   };
#
# ===========================================================================
class UnionKey < XDR::Enum
  member :error, 0
  member :multi, 1

  seal
end
