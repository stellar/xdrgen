defmodule MyXDR.MyUnion do
  @moduledoc """
  Automatically generated by xdrgen
  DO NOT EDIT or your changes may be overwritten

  Target implementation: elixir_xdr at https://hex.pm/packages/elixir_xdr

  Representation of Stellar `MyUnion` type.
  """

  @behaviour XDR.Declaration

  alias MyXDR.{
    UnionKey,
    Error,
    build_type(VariableArray, max_length: 2147483647, type: Multi)
  }

  @arms [
    ERROR: Error,
    MULTI: build_type(VariableArray, max_length: 2147483647, type: Multi)
  ]

  @type value ::
          Error.t()
          | build_type(VariableArray, max_length: 2147483647, type: Multi).t()

  @type t :: %__MODULE__{value: value(), type: UnionKey.t()}

  defstruct [:value, :type]

  @spec new(value :: value(), type :: UnionKey.t()) :: t()
  def new(value, %UnionKey{} = type), do: %__MODULE__{value: value, type: type}

  @impl true
  def encode_xdr(%__MODULE__{value: value, type: type}) do
    type
    |> XDR.Union.new(@arms, value)
    |> XDR.Union.encode_xdr()
  end

  @impl true
  def encode_xdr!(%__MODULE__{value: value, type: type}) do
    type
    |> XDR.Union.new(@arms, value)
    |> XDR.Union.encode_xdr!()
  end

  @impl true
  def decode_xdr(bytes, spec \\ union_spec())

  def decode_xdr(bytes, spec) do
    case XDR.Union.decode_xdr(bytes, spec) do
      {:ok, {{type, value}, rest}} -> {:ok, {new(value, type), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, spec \\ union_spec())

  def decode_xdr!(bytes, spec) do
    {{type, value}, rest} = XDR.Union.decode_xdr!(bytes, spec)
    {new(value, type), rest}
  end

  @spec union_spec() :: XDR.Union.t()
  defp union_spec do
    nil
    |> UnionKey.new()
    |> XDR.Union.new(@arms)
  end
end