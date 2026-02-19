# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct MyStruct {
#       int field1;
#       MyEnum field2;
#                   
#       unsigned int field3;
#         
#   };
#
# ===========================================================================
class MyStruct < XDR::Struct
  attribute :field1, XDR::Int
  attribute :field2, MyEnum
  attribute :field3, XDR::UnsignedInt
end
