defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:13:23+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      typedef int Arr[2];

  ===========================================================================
  """
  define_type("Arr", Array, length: 2, type: buid_type(base_ref))

  comment ~S"""
  === xdr source ============================================================

      struct HasOptions
      {
        int* firstOption;
        int *secondOption;
        Arr *thirdOption;
      };

  ===========================================================================
  """
  define_type("HasOptions", Struct,
    first_option: build_type(Optional, buid_type(base_ref)),
    second_option: build_type(Optional, buid_type(base_ref)),
    third_option: build_type(Optional, "Arr")
  )

end
