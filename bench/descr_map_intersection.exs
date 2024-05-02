defmodule Bench do
  # This benchmark is a simplified version of what is done to intersect map literal types
  # in the new Elixir type system.
  # https://github.com/elixir-lang/elixir/pull/13512/files#diff-aa0ec59e39292db674f5a43fecfb8255a476733798b188ec48f4b39887004775R653-R674

  def existing(map1, map2) do
    (for {key, value} <- map1 do
       value2 = Map.get(map2, key, 0)
       t = value + value2
       {key, t}
     end ++
       for {key, value} <- map2, not is_map_key(map1, key) do
         {key, value}
       end)
    |> Map.new()
  end

  def merge_with(left, right) do
    :maps.merge_with(fn _, l, r -> l + r end, left, right)
  end

  def merge_static(left, right) do
    # Erlang maps:merge_with/3 has to preserve the order in combiner.
    # We don't care about the order, so we have a faster implementation.
    if map_size(left) > map_size(right) do
      iterator_merge(:maps.next(:maps.iterator(right)), left)
    else
      iterator_merge(:maps.next(:maps.iterator(left)), right)
    end
  end

  defp iterator_merge({key, v1, iterator}, map) do
    acc =
      case map do
        %{^key => v2} -> %{map | key => v1 + v2}
        %{} -> Map.put(map, key, v1)
      end

    iterator_merge(:maps.next(iterator), acc)
  end

  defp iterator_merge(:none, map), do: map
end

small = Map.new(1..10, &{:"x#{&1}", &1})
big = Map.new(5..100, &{:"x#{&1}", &1})

inputs = [
  "small - small": {big, small},
  "small - big": {small, big},
  "big - small": {big, small},
  "big - big": {big, big}
]

Benchee.run(
  [
    existing: fn {l, r} -> Bench.existing(l, r) end,
    merge_with: fn {l, r} -> Bench.merge_with(l, r) end,
    merge_static: fn {l, r} -> Bench.merge_static(l, r) end
  ],
  inputs: inputs,
  memory_time: 0.5
)
