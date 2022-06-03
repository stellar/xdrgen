# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Color3 {
#       RED3=RED,  
#       GREEN3=1000,  
#       BLUE3=2000  
#   };
#
# ===========================================================================
class Color3 < XDR::Enum
  member :red3,   0
  member :green3, 1000
  member :blue3,  2000

  seal
end
