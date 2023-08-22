# Comparing implementations of Enum.sum/2

range = 1..1000
list = Enum.map(range, &%{x: &1})

defmodule Candidate do
  def reduce_based(enumerable, fun) when is_function(fun, 1) do
    reduce(enumerable, 0, fn x, acc -> acc + fun.(x) end)
  end

  def specialized(list, fun) when is_list(list) and is_function(fun, 1),
    do: sum_list(list, fun, 0)

  def specialized(enumerable, fun) when is_function(fun, 1) do
    reduce(enumerable, 0, fn x, acc -> acc + fun.(x) end)
  end

  defp sum_list([], _, acc), do: acc
  defp sum_list([h | t], fun, acc), do: sum_list(t, fun, acc + fun.(h))

  # reproduce Enum module condition:
  @compile :inline_list_funcs
  @compile {:inline, reduce: 3}

  def reduce(enumerable, acc, fun) when is_list(enumerable) do
    :lists.foldl(fun, acc, enumerable)
  end
end

defmodule Bench do
  def reduce_based(list), do: Candidate.reduce_based(list, & &1.x)
  def specialized(list), do: Candidate.specialized(list, & &1.x)
end

Benchee.run(%{
  "reduce_based" => fn -> Bench.reduce_based(list) end,
  "specialized" => fn -> Bench.specialized(list) end
})
