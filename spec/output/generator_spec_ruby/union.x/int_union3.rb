# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   union IntUnion3 switch (int type)
#   {
#       case 0:
#           Error error;
#       case 1000:
#           Multi things<>;
#   
#   };
#
# ===========================================================================
class IntUnion3 < XDR::Union
  switch_on XDR::Int, :type

  switch 0,    :error
  switch 1000, :things

  attribute :error,  Error
  attribute :things, XDR::VarArray[Multi]
end
