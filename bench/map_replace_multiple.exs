# %{a: nil, ... A: nil, ...}
# avoid too small maps to prevent fast execution warnings
map = for range <- [?a..?z, ?A..?Z], c <- range, into: %{}, do: {:"#{<<c>>}", nil}

defmodule Bench do
  def multiple_replace(map) do
    map
    |> Map.replace!(:a, 1)
    |> Map.replace!(:b, 2)
    |> Map.replace!(:c, 3)
    |> Map.replace!(:d, 4)
    |> Map.replace!(:e, 5)
  end

  def struct_update(map) do
   %{map | a: 1, b: 2, c: 3, d: 4, e: 5}
  end

  def merge(map) do
    Map.merge(map, %{a: 1, b: 2, c: 3, d: 4, e: 5})
  end
end

Benchee.run(%{
  "erlang := syntax" => fn -> :erl_map_put.replace_keys(map) end,
  "elixir struct update syntax" => fn -> Bench.struct_update(map) end,
  "multiple Map.replace!/3" => fn -> Bench.multiple_replace(map) end,
  "Map.merge/2" => fn -> Bench.merge(map) end
}, memory_time: 0.5)
