# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum Color {
#     RED,
#     BLUE = 5,
#     GREEN
#   };
#
# ===========================================================================
module MyNamespace
  class Color < XDR::Enum
    member :red,   0
    member :blue,  5
    member :green, 6

    seal
  end
end
