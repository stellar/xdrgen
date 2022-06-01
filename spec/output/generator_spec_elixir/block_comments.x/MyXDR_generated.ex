defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:25:17+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      enum AccountFlags
      { // masks for each flag
          AUTH_REQUIRED_FLAG = 0x1
      };

  ===========================================================================
  """
  define_type("AccountFlags", Enum,
    auth_required_flag: 1
  )

end
