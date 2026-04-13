kw = Enum.map(1..10, &{:"foo#{&1}", &1})
keys = Keyword.keys(kw)

defmodule FastKeyword do
  @spec validate(keyword(), values :: [atom() | {atom(), term()}]) ::
          {:ok, keyword()} | {:error, [atom]}
  def validate(keyword, values) when is_list(keyword) and is_list(values) do
    validate(keyword, values, [], keyword, [])
  end

  defp validate([{key, _} | keyword], values1, values2, original, bad_keys) when is_atom(key) do
    case find_key!(key, values1, values2) do
      {values1, values2} ->
        validate(keyword, values1, values2, original, bad_keys)

      :error ->
        case find_key!(key, values2, values1) do
          {values1, values2} ->
            validate(keyword, values1, values2, original, bad_keys)

          :error ->
            validate(keyword, values1, values2, original, [key | bad_keys])
        end
    end
  end

  defp validate([], values1, values2, original, []) do
    {:ok, move_pairs!(values1, move_pairs!(values2, original))}
  end

  defp validate([], _values1, _values2, _original, bad_keys) do
    {:error, bad_keys}
  end

  defp validate([pair | _], _values1, _values2, _original, []) do
    raise ArgumentError,
          "expected a keyword list as first argument, got invalid entry: #{inspect(pair)}"
  end

  # @compile {:inline, find_key!: 3}

  defp find_key!(key, [key | rest], acc), do: {rest, acc}
  defp find_key!(key, [{key, _} | rest], acc), do: {rest, acc}
  defp find_key!(key, [head | tail], acc), do: find_key!(key, tail, [head | acc])
  defp find_key!(_key, [], _acc), do: :error

  defp move_pairs!([key | rest], acc) when is_atom(key),
    do: move_pairs!(rest, acc)

  defp move_pairs!([{key, _} = pair | rest], acc) when is_atom(key),
    do: move_pairs!(rest, [pair | acc])

  defp move_pairs!([], acc),
    do: acc

  defp move_pairs!([other | _], _) do
    raise ArgumentError,
          "expected the second argument to be a list of atoms or tuples, got: #{inspect(other)}"
  end
end

Benchee.run(
  %{
    "original" => fn -> Keyword.validate(kw, keys) end,
    "candidate" => fn -> FastKeyword.validate(kw, keys) end
  },
  memory_time: 0.5
)
