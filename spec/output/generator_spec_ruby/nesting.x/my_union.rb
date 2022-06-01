# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   union MyUnion switch (UnionKey type)
#   {
#       case ONE:
#           struct {
#               int someInt;
#           } one;
#   
#       case TWO:
#           struct {
#               int someInt;
#               Foo foo;
#           } two;
#   
#       case OFFER:
#           void;
#   };
#
# ===========================================================================
class MyUnion < XDR::Union
  include XDR::Namespace

  autoload :One
  autoload :Two

  switch_on UnionKey, :type

  switch :one, :one
  switch :two, :two
  switch :offer

  attribute :one, One
  attribute :two, Two
end
