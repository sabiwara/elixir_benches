inputs =
  for n <- [10, 100, 1000, 10_000, 100_000] do
    set = MapSet.new(1..n)
    {to_string(n), set}
  end

defmodule Bench do
  def sum(set), do: Enum.reduce(set, 0, &+/2)
  def sum2(set), do: optimized_reduce(set, 0, &+/2)
  def reverse(set), do: Enum.reduce(set, [], &[&1 | &2])
  def reverse2(set), do: optimized_reduce(set, [], &[&1 | &2])

  def optimized_reduce(%MapSet{map: map}, acc, fun) do
    :sets.fold(fun, acc, map)
  end
end

# For big lists, "optimized" actually has a higher memory footprint.
Benchee.run(
  %{
    "Enum (sum)" => &Bench.sum/1,
    "optimized (sum)" => &Bench.sum2/1,
    "Enum (reverse)" => &Bench.reverse/1,
    "optimized (reverse)" => &Bench.reverse2/1
  },
  inputs: inputs,
  time: 2,
  memory_time: 0.5
)
