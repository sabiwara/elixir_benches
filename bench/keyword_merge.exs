kw1 = Enum.map(1..10, &{:"foo#{&1}", &1})
kw2 = Enum.map(6..15, &{:"foo#{&1}", &1})

defmodule OptimizedKeyword do
  def merge(keywords1, keywords2)

  def merge(keywords1, []) when is_list(keywords1), do: keywords1
  def merge([], keywords2) when is_list(keywords2), do: keywords2

  def merge(keywords1, keywords2) when is_list(keywords1) and is_list(keywords2) do
    keys2 = collect_keys!(keywords2)

    fun = fn
      {key, _value} when is_atom(key) ->
        not Map.has_key?(keys2, key)

      _ ->
        raise ArgumentError,
              "expected a keyword list as the first argument, got: #{inspect(keywords1)}"
    end

    :lists.filter(fun, keywords1) ++ keywords2
  end

  defp collect_keys!(list), do: collect_keys!(list, %{}, list)

  defp collect_keys!([{key, _} | rest], acc, original) when is_atom(key),
    do: collect_keys!(rest, Map.put(acc, key, []), original)

  defp collect_keys!([], acc, _original), do: acc

  defp collect_keys!(_other, _acc, original) do
    raise ArgumentError,
          "expected a keyword list as the second argument, got: #{inspect(original)}"
  end
end

Benchee.run(
  %{
    "1.19" => fn -> Keyword.merge(kw1, kw2) end,
    "main" => fn -> OptimizedKeyword.merge(kw1, kw2) end
  },
  memory_time: 0.5
)
