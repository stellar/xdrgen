# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Red {
#       RED1=1,
#       RED2=2,
#       RED3=3
#   };
#
# ===========================================================================
class Red < XDR::Enum
  member :red1, 1
  member :red2, 2
  member :red3, 3

  seal
end
