# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct HasOptions
#   {
#     int* firstOption;
#     int *secondOption;
#     Arr *thirdOption;
#   };
#
# ===========================================================================
class HasOptions < XDR::Struct
  attribute :first_option,  XDR::Option[Int]
  attribute :second_option, XDR::Option[Int]
  attribute :third_option,  XDR::Option[Arr]
end
