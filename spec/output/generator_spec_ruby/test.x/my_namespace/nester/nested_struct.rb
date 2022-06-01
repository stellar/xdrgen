# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#       int blah;
#     }
#
# ===========================================================================
module MyNamespace
  class Nester
    class NestedStruct < XDR::Struct
      attribute :blah, XDR::Int
    end
  end
end
