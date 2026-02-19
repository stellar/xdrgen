# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct VariantStruct {
#       int newField;
#   };
#
# ===========================================================================
class VariantStruct < XDR::Struct
  attribute :new_field, XDR::Int
end
