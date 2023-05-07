defmodule Bench do
  def bench1(x), do: Enum.map(x, fn {x, y} -> {y, x} end)
  def bench2(x), do: Enum.reduce(x, [], fn {x, y}, acc -> [{y, x} | acc] end) |> :lists.reverse()
  def bench3(x), do: new_map(x, fn {x, y} -> {y, x} end)

  def new_map(%{} = enumerable, fun) do
    :maps.fold(fn k, v, acc -> [fun.({k, v}) | acc] end, [], enumerable)
  end
end

map = Map.new(1..100, &{&1, &1 + 1})

Benchee.run(%{
  "Enum.map" => fn -> Bench.bench1(map) end,
  "Enum.reduce |> reverse" => fn -> Bench.bench2(map) end,
  "new_map" => fn -> Bench.bench3(map) end,
},
time: 4,
memory_time: 0.5
)
