# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   union MyUnion switch (UnionKey type)
#   {
#       case ERROR:
#           Error error;
#       case MULTI:
#           Multi things<>;
#   
#   
#   };
#
# ===========================================================================
class MyUnion < XDR::Union
  switch_on UnionKey, :type

  switch :error, :error
  switch :multi, :things

  attribute :error,  Error
  attribute :things, XDR::VarArray[Multi]
end
