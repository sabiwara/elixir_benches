defmodule Bench do
  def bench1(x), do: Enum.map(x, & &1 + 1)
  def bench2(x), do: Enum.reduce(x, [], &[&1 + 1 | &2]) |> :lists.reverse()
  def bench3(x), do: new_map(x, & &1 + 1)

  defp new_map(enumerable, fun) do
    Enumerable.reduce(enumerable, {:cont, []}, fn x, acc -> {:cont, [fun.(x) | acc]} end)
    |> elem(1)
    |> :lists.reverse()
  end
end

map_set = MapSet.new(1..100)

Benchee.run(%{
  "Enum.map" => fn -> Bench.bench1(map_set) end,
  "Enum.reduce |> reverse" => fn -> Bench.bench2(map_set) end,
  "new_map" => fn -> Bench.bench3(map_set) end,
},
time: 4,
memory_time: 0.5
)
