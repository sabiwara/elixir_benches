range = 1..50
map = Map.new(range, &{&1, &1})

defmodule Bench do
  def multiple_put(map) do
    map
    |> Map.put(:a, 1)
    |> Map.put(:b, 2)
    |> Map.put(:c, 3)
    |> Map.put(:d, 4)
    |> Map.put(:e, 5)
  end

  def merge(map) do
    Map.merge(map, %{a: 1, b: 2, c: 3, d: 4, e: 5})
  end
end

Benchee.run(%{
  "erlang => syntax" => fn -> :erl_map_put.add_keys(map) end,
  "multiple Map.put/3" => fn -> Bench.multiple_put(map) end,
  "Map.merge/2" => fn -> Bench.merge(map) end
}, memory_time: 0.5)
