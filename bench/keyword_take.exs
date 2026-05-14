:rand.seed(:exsss, {100, 101, 102})
kw = Enum.map(1..10, &{:"foo#{&1}", &1})
keys = Keyword.keys(kw) |> Enum.shuffle()

defmodule OptimizedKeyword do
  def take(keywords, keys) when is_list(keywords) and is_list(keys) do
    :lists.filter(in_keys_check(keys), keywords)
  end

  defp in_keys_check(keys) do
    keys_set = :lists.foldl(fn key, acc -> Map.put(acc, key, true) end, %{}, keys)
    fn {key, _} -> Map.has_key?(keys_set, key) end
  end
end

Benchee.run(
  %{
    "1.19" => fn -> Keyword.take(kw, keys) end,
    "main" => fn -> OptimizedKeyword.take(kw, keys) end
  },
  memory_time: 0.5
)
