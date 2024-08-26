inputs = [
  "range 50": -50..50,
  "range 500": -500..500,
  "list 50": Enum.to_list(-50..50),
  "list 500": Enum.to_list(-500..500)
]

defmodule Optimized do
  def flat_map(enumerable, fun) when is_list(enumerable) do
    flat_map_list(enumerable, fun)
  end

  def flat_map(enumerable, fun) do
    Enum.reduce(enumerable, [], fn entry, acc ->
      case fun.(entry) do
        [] -> acc
        list when is_list(list) -> [list | acc]
        other -> [Enum.to_list(other) | acc]
      end
    end)
    |> flat_reverse([])
  end

  # the first clause is an optimization
  defp flat_reverse([[elem] | t], acc), do: flat_reverse(t, [elem | acc])
  defp flat_reverse([h | t], acc), do: flat_reverse(t, h ++ acc)
  defp flat_reverse([], acc), do: acc

  defp flat_map_list([], _fun), do: []

  defp flat_map_list([head | tail], fun) do
    case fun.(head) do
      # the two first clauses are an optimization
      [] -> flat_map_list(tail, fun)
      [elem] -> [elem | flat_map_list(tail, fun)]
      list when is_list(list) -> list ++ flat_map_list(tail, fun)
      other -> Enum.to_list(other) ++ flat_map_list(tail, fun)
    end
  end
end

defmodule Bench do
  def optimized(enum) do
    Optimized.flat_map(enum, fn x ->
      if x > 0, do: [x + 1], else: []
    end)
  end

  def enum(enum) do
    Enum.flat_map(enum, fn x ->
      if x > 0, do: [x + 1], else: []
    end)
  end
end

Benchee.run(
  %{
    "Enum" => &Bench.enum/1,
    "Optimized" => &Bench.optimized/1
  },
  memory_time: 0.5,
  inputs: inputs
)
