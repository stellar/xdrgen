# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Color3 {
#       RED_1=1,
#       RED_2_TWO=2,
#       RED_3=3
#   };
#
# ===========================================================================
class Color3 < XDR::Enum
  member :red_1,     1
  member :red_2_two, 2
  member :red_3,     3

  seal
end
