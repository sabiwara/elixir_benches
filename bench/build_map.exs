range = 1..100

defmodule Bench do
  def with_reverse(enum) do
    Enum.reduce(enum, [], fn x, acc -> [{x, x} | acc] end)
    |> :lists.reverse()
    |> :maps.from_list()
  end

  def without_reverse(enum) do
    Enum.reduce(enum, [], fn x, acc -> [{x, x} | acc] end)
    |> :maps.from_list()
  end

  def into(enum) do
    Enum.into(enum, %{}, fn x -> {x, x} end)
  end

  def direct(enum) do
    Enum.reduce(enum, %{}, fn x, acc -> Map.put(acc, x, x) end)
  end
end

Benchee.run(
  %{
    "with_reverse" => fn -> Bench.with_reverse(range) end,
    "without_reverse" => fn -> Bench.without_reverse(range) end,
    "into" => fn -> Bench.into(range) end,
    "direct" => fn -> Bench.direct(range) end
  },
  memory_time: 1,
  reduction_time: 1
)
