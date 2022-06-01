# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Color2 {
#       RED2=RED,  
#       GREEN2=1,  
#       BLUE2=2  
#   };
#
# ===========================================================================
class Color2 < XDR::Enum
  member :red2,   0
  member :green2, 1
  member :blue2,  2

  seal
end
