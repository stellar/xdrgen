# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct MyStruct
#   {
#       uint512 field1;
#       optHash1 field2;
#       int1 field3;
#       unsigned int field4;
#       float field5;
#       double field6;
#       bool field7;
#   };
#
# ===========================================================================
module MyNamespace
  class MyStruct < XDR::Struct
    attribute :field1, Uint512
    attribute :field2, OptHash1
    attribute :field3, Int1
    attribute :field4, XDR::UnsignedInt
    attribute :field5, XDR::Float
    attribute :field6, XDR::Double
    attribute :field7, XDR::Bool
  end
end
