defmodule Bench do
  def naive_uniq(enum) do
    Enum.uniq(enum -- Enum.uniq(enum))
  end

  def naive_freq(enum) do
    for {x, c} when c > 1 <- Enum.frequencies(enum), do: x
  end

  def duplicates_body(enum) when is_list(enum) do
    list_duplicates(enum, %{})
  end

  defp list_duplicates([], _map), do: []

  defp list_duplicates([x | xs], map) do
    case map do
      %{^x => true} -> list_duplicates(xs, map)
      %{^x => false} -> [x | list_duplicates(xs, Map.put(map, x, true))]
      _ -> list_duplicates(xs, Map.put(map, x, false))
    end
  end

  def duplicates_tail(enum) when is_list(enum) do
    list_duplicates(enum, [], %{})
  end

  defp list_duplicates([], acc, _map), do: :lists.reverse(acc)

  defp list_duplicates([x | xs], acc, map) do
    case map do
      %{^x => true} -> list_duplicates(xs, acc, map)
      %{^x => false} -> list_duplicates(xs, [x | acc], Map.put(map, x, true))
      _ -> list_duplicates(xs, acc, Map.put(map, x, false))
    end
  end
end

inputs = [
  {"no duplicate", Enum.to_list(1..100)},
  {"half duplicates", Enum.concat(1..50, 50..1//-1)},
  {"many same duplicates", List.duplicate(1, 50) ++ List.duplicate(2, 50)},
  {"big no duplicate", Enum.to_list(1..100_000)}
]

Benchee.run(
  %{
    "naive_uniq" => &Bench.naive_uniq/1,
    "naive_frequencies" => &Bench.naive_freq/1,
    "duplicates (body recursive)" => &Bench.duplicates_body/1,
    "duplicates (tail recursive)" => &Bench.duplicates_tail/1
  },
  inputs: inputs,
  memory_time: 0.5
)
