# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   union switch (Color color) {
#       case RED:
#         void;
#       default:
#         int blah2;
#     }
#
# ===========================================================================
module MyNamespace
  class Nester
    class NestedUnion < XDR::Union
      switch_on Color, :color

      switch :red
      switch :default, :blah2

      attribute :blah2, XDR::Int
    end
  end
end
