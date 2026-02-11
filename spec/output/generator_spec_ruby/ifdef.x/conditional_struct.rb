# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct ConditionalStruct {
#       int data;
#   };
#
# ===========================================================================
class ConditionalStruct < XDR::Struct
  attribute :data, XDR::Int
end
