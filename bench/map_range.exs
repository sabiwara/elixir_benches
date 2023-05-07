defmodule Bench do
  @compile {:inline, map_range: 4, reduce_range: 5}

  def reduce(first..last//step, acc, fun) when is_function(fun, 2),
    do: reduce_range(first, last, step, acc, fun)

  def map(first..last//step, fun) when is_function(fun, 1), do: map_range(first, last, step, fun)

  def map_with_reduce(first..last//step, fun) when is_function(fun, 1),
    do: reduce_range(first, last, step, [], &[fun.(&1) | &2]) |> :lists.reverse()

  defp map_range(first, last, step, fun)
       when step > 0 and first <= last
       when step < 0 and first >= last do
    [fun.(first) | map_range(first + step, last, step, fun)]
  end

  defp map_range(_first, _last, _step, _fun) do
    []
  end

  defp reduce_range(first, last, step, acc, fun)
       when step > 0 and first <= last
       when step < 0 and first >= last do
    reduce_range(first + step, last, step, fun.(first, acc), fun)
  end

  defp reduce_range(_first, _last, _step, acc, _fun) do
    acc
  end

  def bench1, do: map(1..100, & &1 + 1)
  def bench2, do: map_range(1, 100, 1, & &1 + 1)
  def bench3, do: map_with_reduce(1..100, & &1 + 1)
  def bench4, do: for i <- 1..100, do: i + 1
  # for in Elixir 1.14:
  def bench5, do: Enum.map(1..100, & &1 + 1)
  # for in Elixir 1.15:
  def bench6, do: Enum.reduce(1..100, [], &[&1 + 1 | &2]) |> :lists.reverse()
end

Benchee.run(%{
  "map" => &Bench.bench1/0,
  "map_range" => &Bench.bench2/0,
  "map_with_reduce" => &Bench.bench3/0,
  "for" => &Bench.bench4/0,
  "Enum.map" => &Bench.bench5/0,
  "Enum.reduce |> reverse" => &Bench.bench6/0,
},
time: 4,
memory_time: 0.5
)
