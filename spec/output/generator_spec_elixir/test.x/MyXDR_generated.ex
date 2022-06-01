defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:13:23+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base


  comment ~S"""
  === xdr source ============================================================

      typedef opaque uint512[64];

  ===========================================================================
  """
  define_type("Uint512", Opaque, 64)

  comment ~S"""
  === xdr source ============================================================

      typedef opaque uint513<64>;

  ===========================================================================
  """
  define_type("Uint513", VariableOpaque, 64)

  comment ~S"""
  === xdr source ============================================================

      typedef opaque uint514<>;

  ===========================================================================
  """
  define_type("Uint514", VariableOpaque)

  comment ~S"""
  === xdr source ============================================================

      typedef string str<64>;

  ===========================================================================
  """
  define_type("Str", XDR.Type.String, 64)

  comment ~S"""
  === xdr source ============================================================

      typedef string str2<>;

  ===========================================================================
  """
  define_type("Str2", XDR.Type.String, )

  comment ~S"""
  === xdr source ============================================================

      typedef opaque Hash[32];

  ===========================================================================
  """
  define_type("Hash", Opaque, 32)

  comment ~S"""
  === xdr source ============================================================

      typedef Hash Hashes1[12];

  ===========================================================================
  """
  define_type("Hashes1", Array, length: 12, type: "Hash")

  comment ~S"""
  === xdr source ============================================================

      typedef Hash Hashes2<12>;

  ===========================================================================
  """
  define_type("Hashes2", VariableArray, max_length: 12, type: "Hash")

  comment ~S"""
  === xdr source ============================================================

      typedef Hash Hashes3<>;

  ===========================================================================
  """
  define_type("Hashes3", VariableArray, max_length: 2147483647, type: "Hash")

  comment ~S"""
  === xdr source ============================================================

      typedef Hash *optHash1;

  ===========================================================================
  """
  define_type("OptHash1", Optional, "Hash")

  comment ~S"""
  === xdr source ============================================================

      typedef Hash* optHash2;

  ===========================================================================
  """
  define_type("OptHash2", Optional, "Hash")

  comment ~S"""
  === xdr source ============================================================

      typedef int             int1;

  ===========================================================================
  """
  define_type("Int1", Int)

  comment ~S"""
  === xdr source ============================================================

      typedef hyper           int2;

  ===========================================================================
  """
  define_type("Int2", HyperInt)

  comment ~S"""
  === xdr source ============================================================

      typedef unsigned int    int3;

  ===========================================================================
  """
  define_type("Int3", UnsignedInt)

  comment ~S"""
  === xdr source ============================================================

      typedef unsigned hyper  int4;

  ===========================================================================
  """
  define_type("Int4", UnsignedHyperInt)

  comment ~S"""
  === xdr source ============================================================

      struct MyStruct
      {
          uint512 field1;
          optHash1 field2;
          int1 field3;
          unsigned int field4;
          float field5;
          double field6;
          bool field7;
      };

  ===========================================================================
  """
  define_type("MyStruct", Struct,
    field1: "Uint512",
    field2: "OptHash1",
    field3: "Int1",
    field4: build_type(UnsignedInt),
    field5: build_type(Float),
    field6: build_type(Double),
    field7: build_type(Bool)
  )

  comment ~S"""
  === xdr source ============================================================

      struct LotsOfMyStructs
      {
          MyStruct members<>;
      };

  ===========================================================================
  """
  define_type("LotsOfMyStructs", Struct,
    members: build_type(VariableArray, max_length: 2147483647, type: "MyStruct")
  )

  comment ~S"""
  === xdr source ============================================================

      struct HasStuff
      {
        LotsOfMyStructs data;
      };

  ===========================================================================
  """
  define_type("HasStuff", Struct,
    data: "LotsOfMyStructs"
  )

  comment ~S"""
  === xdr source ============================================================

      enum Color {
        RED,
        BLUE = 5,
        GREEN
      };

  ===========================================================================
  """
  define_type("Color", Enum,
    red: 0,
    blue: 5,
    green: 6
  )

  comment ~S"""
  === xdr source ============================================================

      const FOO = 1244;

  ===========================================================================
  """
  define_type("FOO", Const, 1244);

  comment ~S"""
  === xdr source ============================================================

      const BAR = FOO;

  ===========================================================================
  """
  define_type("BAR", Const, FOO);

  comment ~S"""
  === xdr source ============================================================

      enum {
          BLAH_1,
          BLAH_2
        }

  ===========================================================================
  """
  define_type("NesterNestedEnum", Enum,
    blah1: 0,
    blah2: 1
  )

  comment ~S"""
  === xdr source ============================================================

      struct {
          int blah;
        }

  ===========================================================================
  """
  define_type("NesterNestedStruct", Struct,
    blah: build_type(Int)
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (Color color) {
          case RED:
            void;
          default:
            int blah2;
        }

  ===========================================================================
  """
  define_type("NesterNestedUnion", Union,
    switch_type: "Color",
    switch_name: :color,
    switches: [
      {:red, XDR.Type.Void},
    ],
    arms: [
      blah2: build_type(Int),
    ],
    default_arm: blah2,
  )

  comment ~S"""
  === xdr source ============================================================

      struct Nester
      {
        enum {
          BLAH_1,
          BLAH_2
        } nestedEnum;
      
        struct {
          int blah;
        } nestedStruct;
      
        union switch (Color color) {
          case RED:
            void;
          default:
            int blah2;
        } nestedUnion;
      
      
      };

  ===========================================================================
  """
  define_type("Nester", Struct,
    nested_enum: "NesterNestedEnum",
    nested_struct: "NesterNestedStruct",
    nested_union: "NesterNestedUnion"
  )

end
