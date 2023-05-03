defmodule Int do
  @moduledoc """
  Representation of Stellar `Int` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: integer()}

  defstruct [:datum]

  @spec new(int :: integer()) :: t()
  def new(int), do: %__MODULE__{datum: int}

  @impl true
  def encode_xdr(%__MODULE__{datum: int}) do
    XDR.Int.encode_xdr(%XDR.Int{datum: int})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: int}) do
    XDR.Int.encode_xdr!(%XDR.Int{datum: int})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.Int.decode_xdr(bytes) do
      {:ok, {%XDR.Int{datum: int}, rest}} -> {:ok, {new(int), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.Int{datum: int}, rest} = XDR.Int.decode_xdr!(bytes)
    {new(int), rest}
  end
end

defmodule UInt do
  @moduledoc """
  Representation of Stellar `UInt` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: non_neg_integer()}

  defstruct [:datum]

  @spec new(uint :: non_neg_integer()) :: t()
  def new(uint), do: %__MODULE__{datum: uint}

  @impl true
  def encode_xdr(%__MODULE__{datum: uint}) do
    XDR.UInt.encode_xdr(%XDR.UInt{datum: uint})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: uint}) do
    XDR.UInt.encode_xdr!(%XDR.UInt{datum: uint})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.UInt.decode_xdr(bytes) do
      {:ok, {%XDR.UInt{datum: uint}, rest}} -> {:ok, {new(uint), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.UInt{datum: uint}, rest} = XDR.UInt.decode_xdr!(bytes)
    {new(uint), rest}
  end
end

defmodule Float do
  @moduledoc """
  Representation of Stellar `Float` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: float()}

  defstruct [:datum]

  @spec new(float :: float()) :: t()
  def new(float), do: %__MODULE__{datum: float}

  @impl true
  def encode_xdr(%__MODULE__{datum: float}) do
    XDR.Float.encode_xdr(%XDR.Float{datum: float})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: float}) do
    XDR.Float.encode_xdr!(%XDR.Float{datum: float})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.Float.decode_xdr(bytes) do
      {:ok, {%XDR.Float{datum: float}, rest}} -> {:ok, {new(float), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.Float{datum: float}, rest} = XDR.Float.decode_xdr!(bytes)
    {new(float), rest}
  end
end

defmodule DoubleFloat do
  @moduledoc """
  Representation of Stellar `DoubleFloat` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: float()}

  defstruct [:datum]

  @spec new(float :: float()) :: t()
  def new(float), do: %__MODULE__{datum: float}

  @impl true
  def encode_xdr(%__MODULE__{datum: float}) do
    XDR.DoubleFloat.encode_xdr(%XDR.DoubleFloat{datum: float})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: float}) do
    XDR.DoubleFloat.encode_xdr!(%XDR.DoubleFloat{datum: float})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.DoubleFloat.decode_xdr(bytes) do
      {:ok, {%XDR.DoubleFloat{datum: float}, rest}} -> {:ok, {new(float), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.DoubleFloat{datum: float}, rest} = XDR.DoubleFloat.decode_xdr!(bytes)
    {new(float), rest}
  end
end

defmodule HyperUInt do
  @moduledoc """
  Representation of Stellar `HyperUInt` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{datum: non_neg_integer()}

  defstruct [:datum]

  @spec new(uint :: non_neg_integer()) :: t()
  def new(uint), do: %__MODULE__{datum: uint}

  @impl true
  def encode_xdr(%__MODULE__{datum: uint}) do
    XDR.HyperUInt.encode_xdr(%XDR.HyperUInt{datum: uint})
  end

  @impl true
  def encode_xdr!(%__MODULE__{datum: uint}) do
    XDR.HyperUInt.encode_xdr!(%XDR.HyperUInt{datum: uint})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.HyperUInt.decode_xdr(bytes) do
      {:ok, {%XDR.HyperUInt{datum: uint}, rest}} -> {:ok, {new(uint), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.HyperUInt{datum: uint}, rest} = XDR.HyperUInt.decode_xdr!(bytes)
    {new(uint), rest}
  end
end

defmodule Bool do
  @moduledoc """
  Representation of Stellar `Bool` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{value: boolean()}

  defstruct [:value]

  @spec new(value :: boolean()) :: t()
  def new(val), do: %__MODULE__{value: val}

  @impl true
  def encode_xdr(%__MODULE__{value: value}) do
    XDR.Bool.encode_xdr(%XDR.Bool{identifier: value})
  end

  @impl true
  def encode_xdr!(%__MODULE__{value: value}) do
    XDR.Bool.encode_xdr!(%XDR.Bool{identifier: value})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.Bool.decode_xdr(bytes) do
      {:ok, {%XDR.Bool{identifier: val}, rest}} -> {:ok, {new(val), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.Bool{identifier: val}, rest} = XDR.Bool.decode_xdr!(bytes)
    {new(val), rest}
  end
end

defmodule String do
  @moduledoc """
  Representation of Stellar `String` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{value: String.t()}

  defstruct [:value]

  @spec new(value :: String.t()) :: t()
  def new(value), do: %__MODULE__{value: value}

  @impl true
  def encode_xdr(%__MODULE__{value: value}) do
    value
    |> XDR.String.new()
    |> XDR.String.encode_xdr()
  end

  @impl true
  def encode_xdr!(%__MODULE__{value: value}) do
    value
    |> XDR.String.new()
    |> XDR.String.encode_xdr!()
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.String.decode_xdr(bytes) do
      {:ok, {%XDR.String{string: value}, rest}} -> {:ok, {new(value), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {%XDR.String{string: value}, rest} = XDR.String.decode_xdr!(bytes)
    {new(value), rest}
  end
end

defmodule FixedOpaque do
  @moduledoc """
  Representation of Stellar `FixedOpaque` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{opaque: binary()}

  defstruct [:opaque]

  @length = 4_294_967_295

  @opaque_spec XDR.FixedOpaque.new(nil, @length)

  @spec new(opaque :: binary()) :: t()
  def new(opaque), do: %__MODULE__{opaque: opaque}

  @impl true
  def encode_xdr(%__MODULE__{opaque: opaque}) do
    XDR.FixedOpaque.encode_xdr(%XDR.FixedOpaque{opaque: opaque, length: @length})
  end

  @impl true
  def encode_xdr!(%__MODULE__{opaque: opaque}) do
    XDR.FixedOpaque.encode_xdr!(%XDR.FixedOpaque{opaque: opaque, length: @length})
  end

  @impl true
  def decode_xdr(bytes, spec \\ @opaque_spec)

  def decode_xdr(bytes, spec) do
    case XDR.FixedOpaque.decode_xdr(bytes, spec) do
      {:ok, {%XDR.FixedOpaque{opaque: opaque}, rest}} -> {:ok, {new(opaque), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, spec \\ @opaque_spec)

  def decode_xdr!(bytes, spec) do
    {%XDR.FixedOpaque{opaque: opaque}, rest} = XDR.FixedOpaque.decode_xdr!(bytes, spec)
    {new(opaque), rest}
  end
end

defmodule VariableOpaque do
  @moduledoc """
  Representation of Stellar `VariableOpaque` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{opaque: binary()}

  defstruct [:opaque]

  @opaque_spec XDR.VariableOpaque.new(nil)

  @spec new(opaque :: binary()) :: t()
  def new(opaque), do: %__MODULE__{opaque: opaque}

  @impl true
  def encode_xdr(%__MODULE__{opaque: opaque}) do
    XDR.VariableOpaque.encode_xdr(%XDR.VariableOpaque{opaque: opaque})
  end

  @impl true
  def encode_xdr!(%__MODULE__{opaque: opaque}) do
    XDR.VariableOpaque.encode_xdr!(%XDR.VariableOpaque{opaque: opaque})
  end

  @impl true
  def decode_xdr(bytes, spec \\ @opaque_spec)

  def decode_xdr(bytes, spec) do
    case XDR.VariableOpaque.decode_xdr(bytes, spec) do
      {:ok, {%XDR.VariableOpaque{opaque: opaque}, rest}} -> {:ok, {new(opaque), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, spec \\ @opaque_spec)

  def decode_xdr!(bytes, spec) do
    {%XDR.VariableOpaque{opaque: opaque}, rest} = XDR.VariableOpaque.decode_xdr!(bytes, spec)
    {new(opaque), rest}
  end
end

defmodule Void do
  @moduledoc """
  Representation of Stellar `Void` type.
  """

  @behaviour XDR.Declaration

  @type t :: %__MODULE__{value: nil}

  defstruct [:value]

  @spec new(value :: nil) :: t()
  def new(_val \\ nil), do: %__MODULE__{value: nil}

  @impl true
  def encode_xdr(%__MODULE__{}) do
    XDR.Void.encode_xdr(%XDR.Void{})
  end

  @impl true
  def encode_xdr!(%__MODULE__{}) do
    XDR.Void.encode_xdr!(%XDR.Void{})
  end

  @impl true
  def decode_xdr(bytes, term \\ nil)

  def decode_xdr(bytes, _term) do
    case XDR.Void.decode_xdr(bytes) do
      {:ok, {nil, rest}} -> {:ok, {new(), rest}}
      error -> error
    end
  end

  @impl true
  def decode_xdr!(bytes, term \\ nil)

  def decode_xdr!(bytes, _term) do
    {nil, rest} = XDR.Void.decode_xdr!(bytes)
    {new(), rest}
  end
end
