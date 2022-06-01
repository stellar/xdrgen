# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#               int someInt;
#               Foo foo;
#           }
#
# ===========================================================================
class MyUnion
  class Two < XDR::Struct
    attribute :some_int, XDR::Int
    attribute :foo,      Foo
  end
end
