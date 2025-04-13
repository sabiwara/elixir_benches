defmodule BaseAlt do
  @type decode_case :: :upper | :lower | :mixed

  b32_alphabet = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  b32hex_alphabet = ~c"0123456789ABCDEFGHIJKLMNOPQRSTUV"

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

  @spec valid32?(binary, case: decode_case, padding: boolean) :: boolean()
  def valid32?(string, opts \\ []) when is_binary(string) do
    pad? = Keyword.get(opts, :padding, true)

    case Keyword.get(opts, :case, :upper) do
      :upper -> validate32upper?(string, pad?)
      :lower -> validate32lower?(string, pad?)
      :mixed -> validate32mixed?(string, pad?)
    end
  end

  @spec hex_valid32?(binary, case: decode_case, padding: boolean) :: boolean
  def hex_valid32?(string, opts \\ []) when is_binary(string) do
    pad? = Keyword.get(opts, :padding, true)

    case Keyword.get(opts, :case, :upper) do
      :upper -> validate32hexupper?(string, pad?)
      :lower -> validate32hexlower?(string, pad?)
      :mixed -> validate32hexmixed?(string, pad?)
    end
  end

  upper = Enum.with_index(b32_alphabet)
  hexupper = Enum.with_index(b32hex_alphabet)

  for {base, alphabet} <- [
        upper: upper,
        lower: to_lower_dec.(upper),
        mixed: to_mixed_dec.(upper),
        hexupper: hexupper,
        hexlower: to_lower_dec.(hexupper),
        hexmixed: to_mixed_dec.(hexupper)
      ] do
    validate_name = :"validate32#{base}?"
    validate_main_name = :"validate_main32#{validate_name}?"
    valid_char_name = :"valid_char32#{base}?"
    {min, decoded} = to_decode_list.(alphabet)

    defp unquote(validate_main_name)(<<>>), do: true

    defp unquote(validate_main_name)(
           <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8, rest::binary>>
         ) do
      unquote(valid_char_name)(c1) and
        unquote(valid_char_name)(c2) and
        unquote(valid_char_name)(c3) and
        unquote(valid_char_name)(c4) and
        unquote(valid_char_name)(c5) and
        unquote(valid_char_name)(c6) and
        unquote(valid_char_name)(c7) and
        unquote(valid_char_name)(c8) and
        unquote(validate_main_name)(rest)
    end

    defp unquote(validate_name)(<<>>, _pad?), do: true

    defp unquote(validate_name)(string, pad?) do
      segs = div(byte_size(string) + 7, 8) - 1
      <<main::size(^segs)-binary-unit(64), rest::binary>> = string
      main_valid? = unquote(validate_main_name)(main)

      case rest do
        _ when not main_valid? ->
          false

        <<c1::8, c2::8, ?=, ?=, ?=, ?=, ?=, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2)

        <<c1::8, c2::8, c3::8, c4::8, ?=, ?=, ?=, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, ?=, ?=, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5) and
            unquote(valid_char_name)(c6) and
            unquote(valid_char_name)(c7)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5) and
            unquote(valid_char_name)(c6) and
            unquote(valid_char_name)(c7) and
            unquote(valid_char_name)(c8)

        <<c1::8, c2::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2)

        <<c1::8, c2::8, c3::8, c4::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4)

        <<c1::8, c2::8, c3::8, c4::8, c5::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5) and
            unquote(valid_char_name)(c6) and
            unquote(valid_char_name)(c7)

        _ ->
          false
      end
    end

    @compile {:inline, [{valid_char_name, 1}]}
    defp unquote(valid_char_name)(char)
         when elem({unquote_splicing(decoded)}, char - unquote(min)) != nil,
         do: true

    defp unquote(valid_char_name)(_char), do: false
  end
end

inputs = [
  "small string": Base.hex_encode32("hello world"),
  "big string": Base.hex_encode32(:crypto.strong_rand_bytes(1_000_000)),
  "invalid string": String.duplicate("1234567890ABCDEF", 10) |> String.replace_trailing("F", "@")
]

Benchee.run(
  %{
    "main" => &Base.hex_valid32?/1,
    "PR" => &BaseAlt.hex_valid32?/1
  },
  inputs: inputs,
  memory_time: 1
)
