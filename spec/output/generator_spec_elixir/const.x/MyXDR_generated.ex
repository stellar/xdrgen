defmodule MyXDR do
  @moduledoc """
  Automatically generated by xdrgen
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      const FOO = 1;

  ===========================================================================
  """
  define_type("FOO", Const, 1);

  comment ~S"""
  === xdr source ============================================================

      typedef int TestArray[FOO];

  ===========================================================================
  """
  define_type("TestArray", Array, length: "FOO", type: buid_type(base_ref))

  comment ~S"""
  === xdr source ============================================================

      typedef int TestArray2<FOO>;

  ===========================================================================
  """
  define_type("TestArray2", VariableArray, max_length: "FOO", type: buid_type(base_ref))

end
