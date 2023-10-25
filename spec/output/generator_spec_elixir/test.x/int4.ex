defmodule MyXDR.Int4 do
  @moduledoc """
  Automatically generated by xdrgen
  DO NOT EDIT or your changes may be overwritten

  Target implementation: elixir_xdr at https://hex.pm/packages/elixir_xdr

  Representation of Stellar `Int4` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: non_neg_integer()}

  defstruct [:datum]

  @spec new(value :: non_neg_integer()) :: t()
  def new(value), do: %__MODULE__{datum: value}

  @impl true
  def encode_xdr(%__MODULE__{datum: value}) do
    XDR.HyperUInt.encode_xdr(%XDR.HyperUInt{datum: value})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: value}) do
    XDR.HyperUInt.encode_xdr!(%XDR.HyperUInt{datum: value})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.HyperUInt.decode_xdr(bytes) do
      {:ok, {%XDR.HyperUInt{datum: value}, rest}} -> {:ok, {new(value), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.HyperUInt{datum: value}, rest} = XDR.HyperUInt.decode_xdr!(bytes)
    {new(value), rest}
  end
end
