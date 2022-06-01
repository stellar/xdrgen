# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#               int someInt;
#           }
#
# ===========================================================================
class MyUnion
  class One < XDR::Struct
    attribute :some_int, XDR::Int
  end
end
