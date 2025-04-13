defmodule BaseAlt do
  @type decode_case :: :upper | :lower | :mixed

  b16_alphabet = ~c"0123456789ABCDEF"

  to_mixed_dec =
    &Enum.flat_map(&1, fn {encoding, value} = pair ->
      if encoding in ?A..?Z do
        [pair, {encoding - ?A + ?a, value}]
      else
        [pair]
      end
    end)

  to_lower_dec =
    &Enum.map(&1, fn {encoding, value} = pair ->
      if encoding in ?A..?Z do
        {encoding - ?A + ?a, value}
      else
        pair
      end
    end)

  to_decode_list = fn alphabet ->
    alphabet = Enum.sort(alphabet)
    map = Map.new(alphabet)
    {min, _} = List.first(alphabet)
    {max, _} = List.last(alphabet)
    {min, Enum.map(min..max, &map[&1])}
  end

  @spec valid16?(binary, case: decode_case) :: boolean
  def valid16?(string, opts \\ [])

  def valid16?(string, opts) when is_binary(string) and rem(byte_size(string), 2) == 0 do
    case Keyword.get(opts, :case, :upper) do
      :upper -> validate16upper?(string)
      :lower -> validate16lower?(string)
      :mixed -> validate16mixed?(string)
    end
  end

  def valid16?(string, _opts) when is_binary(string) do
    false
  end

  upper = Enum.with_index(b16_alphabet)

  for {base, alphabet} <- [upper: upper, lower: to_lower_dec.(upper), mixed: to_mixed_dec.(upper)] do
    validate_name = :"validate16#{base}?"
    valid_char_name = :"valid_char16#{base}?"

    {min, decoded} = to_decode_list.(alphabet)

    defp unquote(validate_name)(<<>>), do: true

    defp unquote(validate_name)(<<c1, c2, rest::binary>>) do
      unquote(valid_char_name)(c1) and
        unquote(valid_char_name)(c2) and
        unquote(validate_name)(rest)
    end

    defp unquote(validate_name)(<<_char, _rest::binary>>), do: false

    @compile {:inline, [{valid_char_name, 1}]}
    defp unquote(valid_char_name)(char)
         when elem({unquote_splicing(decoded)}, char - unquote(min)) != nil,
         do: true

    defp unquote(valid_char_name)(_char), do: false
  end
end

inputs = [
  "small string": Base.encode16("hello world"),
  "big string": Base.encode16(:crypto.strong_rand_bytes(1_000_000)),
  "invalid string": String.duplicate("1234567890ABCDEF", 10) |> String.replace_trailing("F", "@")
]

Benchee.run(
  %{
    # as of 30711a724, before optimizing
    "main" => &Base.valid16?/1,
    "PR" => &BaseAlt.valid16?/1
  },
  inputs: inputs,
  memory_time: 1
)
