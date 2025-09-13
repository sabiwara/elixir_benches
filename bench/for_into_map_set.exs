range = 1..100
inputs = [list: Enum.to_list(range), range: range]

defmodule Bench do
  def comprehension(list) do
    for x <- list, into: MapSet.new(), do: x
  end

  def enum_into(list) do
    Enum.into(list, MapSet.new())
  end

  def map_set_new(list) do
    MapSet.new(list)
  end
end

Benchee.run(
  %{
    "comprehension" => &Bench.comprehension/1,
    "Enum.into" => &Bench.enum_into/1,
    "MapSet.new" => &Bench.map_set_new/1
  },
  inputs: inputs,
  memory_time: 0.5
)
