range = 1..50
map = Map.new(range, &{&1, &1})

inputs =
  Enum.map([5, 20, 100], fn n ->
    range = 1..n//1
    left = Map.new(range, &{&1, &1})
    right = Map.new(range, &{&1, []})
    {"size=#{n}", {left, right}}
  end)

defmodule Bench do
  def using_sort(map1, map2) do
    :maps.keys(map1) |> :lists.sort() == :maps.keys(map2) |> :lists.sort()
  end

  def using_sets(map1, map2) do
    :maps.keys(map1) |> :sets.from_list(version: 2) ==
      :maps.keys(map2) |> :sets.from_list(version: 2)
  end

  def using_all(map1, map2) do
    map_size(map1) === map_size(map2) and
      :maps.keys(map1) |> Enum.all?(fn key -> is_map_key(map2, key) end)
  end
end

Benchee.run(
  %{
    "using_sort" => fn {left, right} -> Bench.using_sort(left, right) end,
    "using_sets" => fn {left, right} -> Bench.using_sets(left, right) end,
    "using_all" => fn {left, right} -> Bench.using_all(left, right) end
  },
  memory_time: 0.5,
  inputs: inputs
)
