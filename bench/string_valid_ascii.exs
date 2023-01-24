defmodule String2 do
  def valid?(string, mode \\ :default)

  def valid?(<<string::binary>>, :default), do: valid_utf8?(string)
  def valid?(<<string::binary>>, :fast_ascii), do: valid_utf8_fast_ascii?(string)

  defp valid_utf8?(<<_::utf8, rest::bits>>), do: valid_utf8?(rest)
  defp valid_utf8?(<<>>), do: true
  defp valid_utf8?(_), do: false

  defp valid_utf8_fast_ascii?(<<a::56, rest::bits>>)
       when Bitwise.band(0x80808080808080, a) == 0 do
    valid_utf8_fast_ascii?(rest)
  end

  defp valid_utf8_fast_ascii?(<<_::utf8, rest::bits>>), do: valid_utf8_fast_ascii?(rest)
  defp valid_utf8_fast_ascii?(<<>>), do: true
  defp valid_utf8_fast_ascii?(_), do: false
end

defmodule AutoDetect do
  # optimistic loop, able to process big ASCII-only binaries very fast
  def valid?(<<a::56, rest::bits>>) when Bitwise.band(0x80808080808080, a) == 0 do
    valid?(rest)
  end

  # slower loop for other cases
  def valid?(other) when is_binary(other), do: valid_non_only_ascii?(other)

  defp valid_non_only_ascii?(<<_::utf8, rest::bits>>), do: valid_non_only_ascii?(rest)
  defp valid_non_only_ascii?(<<>>), do: true
  defp valid_non_only_ascii?(_), do: false
end

defmodule AutoDetectInlined do
  # same as AutoDetect but inlined
  @compile {:inline, valid?: 1, valid_non_only_ascii?: 1}

  def valid?(<<a::56, rest::bits>>) when Bitwise.band(0x80808080808080, a) == 0 do
    valid?(rest)
  end

  def valid?(other) when is_binary(other), do: valid_non_only_ascii?(other)

  defp valid_non_only_ascii?(<<_::utf8, rest::bits>>), do: valid_non_only_ascii?(rest)
  defp valid_non_only_ascii?(<<>>), do: true
  defp valid_non_only_ascii?(_), do: false
end

Benchee.run(
  %{
    "stock" => fn {valid, input} -> ^valid = String.valid?(input) end,
    "fast_ascii" => fn {valid, input} -> ^valid = String2.valid?(input, :fast_ascii) end,
    "auto_detect" => fn {valid, input} -> ^valid = AutoDetect.valid?(input) end,
    "auto_detect (inline)" => fn {valid, input} -> ^valid = AutoDetectInlined.valid?(input) end
  },
  time: 3,
  memory_time: 0.5,
  reduction_time: 0.5,
  inputs: %{
    # 1 => {false, String.duplicate("a", 0) <> <<128::8>>},
    # 4 => {false, String.duplicate("a", 3) <> <<128::8>>},
    # 8 => {false, String.duplicate("a", 7) <> <<128::8>>},
    # 16 => {false, String.duplicate("a", 15) <> <<128::8>>},
    # 32 => {false, String.duplicate("a", 31) <> <<128::8>>},
    64 => {false, String.duplicate("a", 63) <> <<128::8>>},
    # 128 => {false, String.duplicate("a", 127) <> <<128::8>>},
    # 256 => {false, String.duplicate("a", 255) <> <<128::8>>},
    512 => {false, String.duplicate("a", 511) <> <<128::8>>},
    # 1024 => {false, String.duplicate("a", 1023) <> <<128::8>>},
    # 2048 => {false, String.duplicate("a", 2047) <> <<128::8>>},
    4096 => {false, String.duplicate("a", 4095) <> <<128::8>>}
  }
)
