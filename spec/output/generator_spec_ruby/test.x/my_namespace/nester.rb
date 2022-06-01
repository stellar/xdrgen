# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct Nester
#   {
#     enum {
#       BLAH_1,
#       BLAH_2
#     } nestedEnum;
#   
#     struct {
#       int blah;
#     } nestedStruct;
#   
#     union switch (Color color) {
#       case RED:
#         void;
#       default:
#         int blah2;
#     } nestedUnion;
#   
#   
#   };
#
# ===========================================================================
module MyNamespace
  class Nester < XDR::Struct
    include XDR::Namespace

    autoload :NestedEnum
    autoload :NestedStruct
    autoload :NestedUnion

    attribute :nested_enum,   NestedEnum
    attribute :nested_struct, NestedStruct
    attribute :nested_union,  NestedUnion
  end
end
