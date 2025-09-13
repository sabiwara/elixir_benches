range = 1..100
inputs = [list: Enum.to_list(range), range: range]

defmodule Bench do
  def comprehension(enum) do
    for x <- enum, into: %{}, do: {x, x}
  end

  def enum_into(enum) do
    Enum.into(enum, %{}, & {&1, &1})
  end

  def map_set_new(enum) do
    Map.new(enum, & {&1, &1})
  end
end

Benchee.run(
  %{
    "comprehension" => &Bench.comprehension/1,
    "Enum.into" => &Bench.enum_into/1,
    "Map.new" => &Bench.map_set_new/1
  },
  inputs: inputs,
  memory_time: 0.5
)
