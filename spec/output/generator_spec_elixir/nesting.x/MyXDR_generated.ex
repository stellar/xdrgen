defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:25:17+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      enum UnionKey {
        ONE = 1,
        TWO = 2,
        OFFER = 3
      };

  ===========================================================================
  """
  define_type("UnionKey", Enum,
    one: 1,
    two: 2,
    offer: 3
  )

  comment ~S"""
  === xdr source ============================================================

      typedef int Foo;

  ===========================================================================
  """
  define_type("Foo", Int)

  comment ~S"""
  === xdr source ============================================================

      struct {
                  int someInt;
              }

  ===========================================================================
  """
  define_type("MyUnionOne", Struct,
    some_int: build_type(Int)
  )

  comment ~S"""
  === xdr source ============================================================

      struct {
                  int someInt;
                  Foo foo;
              }

  ===========================================================================
  """
  define_type("MyUnionTwo", Struct,
    some_int: build_type(Int),
    foo: "Foo"
  )

  comment ~S"""
  === xdr source ============================================================

      union MyUnion switch (UnionKey type)
      {
          case ONE:
              struct {
                  int someInt;
              } one;
      
          case TWO:
              struct {
                  int someInt;
                  Foo foo;
              } two;
      
          case OFFER:
              void;
      };

  ===========================================================================
  """
  define_type("MyUnion", Union,
    switch_type: "UnionKey",
    switch_name: :type,
    switches: [
      {:one, :one},
      {:two, :two},
      {:offer, XDR.Type.Void},
    ],
    arms: [
      one: "MyUnionOne",
      two: "MyUnionTwo",
    ]
  )

end
