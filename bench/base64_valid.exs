defmodule BaseAlt do
  @type decode_case :: :upper | :lower | :mixed

  b64_alphabet = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  b64url_alphabet = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

  to_decode_list = fn alphabet ->
    alphabet = Enum.sort(alphabet)
    map = Map.new(alphabet)
    {min, _} = List.first(alphabet)
    {max, _} = List.last(alphabet)
    {min, Enum.map(min..max, &map[&1])}
  end

  defp remove_ignored(string, nil), do: string

  defp remove_ignored(string, :whitespace) do
    for <<char::8 <- string>>, char not in ~c"\s\t\r\n", into: <<>>, do: <<char::8>>
  end

  @spec valid64?(binary, ignore: :whitespace, padding: boolean) :: boolean
  def valid64?(string, opts \\ []) when is_binary(string) do
    pad? = Keyword.get(opts, :padding, true)
    string |> remove_ignored(opts[:ignore]) |> validate64base?(pad?)
  end

  @spec url_valid64?(binary, ignore: :whitespace, padding: boolean) :: boolean
  def url_valid64?(string, opts \\ []) when is_binary(string) do
    pad? = Keyword.get(opts, :padding, true)
    string |> remove_ignored(opts[:ignore]) |> validate64url?(pad?)
  end

  for {base, alphabet} <- [base: b64_alphabet, url: b64url_alphabet] do
    validate_name = :"validate64#{base}?"
    validate_main_name = :"validate_main64#{validate_name}?"
    valid_char_name = :"valid_char64#{base}?"
    {min, decoded} = alphabet |> Enum.with_index() |> to_decode_list.()

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

        <<c1::8, c2::8, ?=, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2)

        <<c1::8, c2::8, c3::8, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3)

        <<c1::8, c2::8, c3::8, c4::8>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, ?=, ?=>> ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5) and
            unquote(valid_char_name)(c6)

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

        <<c1::8, c2::8, c3::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3)

        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8>> when not pad? ->
          unquote(valid_char_name)(c1) and
            unquote(valid_char_name)(c2) and
            unquote(valid_char_name)(c3) and
            unquote(valid_char_name)(c4) and
            unquote(valid_char_name)(c5) and
            unquote(valid_char_name)(c6)

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
  "small string": Base.encode64("hello world"),
  "big string": Base.encode64(:crypto.strong_rand_bytes(1_000_000)),
  "invalid string": String.duplicate("1234567890ABCDEF", 10) |> String.replace_trailing("F", "@")
]

Benchee.run(
  %{
    "main" => &Base.valid64?/1,
    "PR" => &BaseAlt.valid64?/1
  },
  inputs: inputs,
  memory_time: 1
)
