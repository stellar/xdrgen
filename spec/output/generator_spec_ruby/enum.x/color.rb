# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Color {
#       RED=0,  
#       GREEN=1,  
#       BLUE=2  
#   };
#
# ===========================================================================
class Color < XDR::Enum
  member :red,   0
  member :green, 1
  member :blue,  2

  seal
end
