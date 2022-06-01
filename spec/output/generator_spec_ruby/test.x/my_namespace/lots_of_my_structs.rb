# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct LotsOfMyStructs
#   {
#       MyStruct members<>;
#   };
#
# ===========================================================================
module MyNamespace
  class LotsOfMyStructs < XDR::Struct
    attribute :members, XDR::VarArray[MyStruct]
  end
end
