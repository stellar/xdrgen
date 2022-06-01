defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:25:17+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      typedef int Error;

  ===========================================================================
  """
  define_type("Error", Int)

  comment ~S"""
  === xdr source ============================================================

      typedef int Multi;

  ===========================================================================
  """
  define_type("Multi", Int)

  comment ~S"""
  === xdr source ============================================================

      enum UnionKey {
        ERROR,
        MULTI
      };

  ===========================================================================
  """
  define_type("UnionKey", Enum,
    error: 0,
    multi: 1
  )

  comment ~S"""
  === xdr source ============================================================

      union MyUnion switch (UnionKey type)
      {
          case ERROR:
              Error error;
          case MULTI:
              Multi things<>;
      
      
      };

  ===========================================================================
  """
  define_type("MyUnion", Union,
    switch_type: "UnionKey",
    switch_name: :type,
    switches: [
      {:error, :error},
      {:multi, :things},
    ],
    arms: [
      error: "Error",
      things: build_type(VariableArray, max_length: 2147483647, type: "Multi"),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      union IntUnion switch (int type)
      {
          case 0:
              Error error;
          case 1:
              Multi things<>;
      
      };

  ===========================================================================
  """
  define_type("IntUnion", Union,
    switch_type: build_type(Int),
    switch_name: :type,
    switches: [
      {0, :error},
      {1, :things},
    ],
    arms: [
      error: "Error",
      things: build_type(VariableArray, max_length: 2147483647, type: "Multi"),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      typedef IntUnion IntUnion2;

  ===========================================================================
  """
  define_type("IntUnion2", "IntUnion")

end
