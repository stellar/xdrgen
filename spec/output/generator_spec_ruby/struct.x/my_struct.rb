# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct MyStruct
#   {
#       int    someInt;
#       int64  aBigInt;
#       opaque someOpaque[10];
#       string someString<>;
#       string maxString<100>;
#   };
#
# ===========================================================================
class MyStruct < XDR::Struct
  attribute :some_int,    XDR::Int
  attribute :a_big_int,   Int64
  attribute :some_opaque, XDR::Opaque[10]
  attribute :some_string, XDR::String[]
  attribute :max_string,  XDR::String[100]
end
