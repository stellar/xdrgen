# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

module MyNamespace
  include XDR::Namespace

  Uint512 = XDR::Opaque[64]
  Uint513 = XDR::VarOpaque[64]
  Uint514 = XDR::VarOpaque[]
  Str = XDR::String[64]
  Str2 = XDR::String[]
  Hash = XDR::Opaque[32]
  Hashes1 = XDR::Array[Hash, 12]
  Hashes2 = XDR::VarArray[Hash, 12]
  Hashes3 = XDR::VarArray[Hash]
  OptHash1 = XDR::Option[Hash]
  OptHash2 = XDR::Option[Hash]
  Int1 = XDR::Int
  Int2 = XDR::Hyper
  Int3 = XDR::UnsignedInt
  Int4 = XDR::UnsignedHyper
  autoload :MyStruct
  autoload :LotsOfMyStructs
  autoload :HasStuff
  autoload :Color
  FOO = 1244
  BAR = FOO
  autoload :Nester
end
