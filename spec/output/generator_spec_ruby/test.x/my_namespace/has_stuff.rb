# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct HasStuff
#   {
#     LotsOfMyStructs data;
#   };
#
# ===========================================================================
module MyNamespace
  class HasStuff < XDR::Struct
    attribute :data, LotsOfMyStructs
  end
end
