inputs = [
  "5 in 50": {5, Enum.to_list(-50..50)},
  "5 in 500": {5, Enum.to_list(-500..500)},
  "1000 in 500": {1000, Enum.to_list(-500..500)}
]

defmodule Optimized do
  def count_until(enumerable, fun, limit) when is_integer(limit) and limit > 0 do
    case enumerable do
      list when is_list(list) -> count_until_list(list, fun, limit, 0)
      _ -> count_until_enum(enumerable, fun, limit)
    end
  end

  @compile {:inline, count_until_list: 4}

  defp count_until_list([], _fun, _limit, acc), do: acc

  defp count_until_list([head | tail], fun, limit, acc) do
    if fun.(head) do
      case acc + 1 do
        ^limit -> limit
        acc -> count_until_list(tail, fun, limit, acc)
      end
    else
      count_until_list(tail, fun, limit, acc)
    end
  end

  defp count_until_enum(enumerable, fun, limit) do
    Enumerable.reduce(enumerable, {:cont, 0}, fn entry, acc ->
      if fun.(entry) do
        case acc + 1 do
          ^limit -> {:halt, limit}
          acc -> {:cont, acc}
        end
      else
        {:cont, acc}
      end
    end)
    |> elem(1)
  end
end

defmodule Bench do
  def optimized({limit, enum}) do
    Optimized.count_until(enum, fn x -> x > 0 end, limit)
  end

  def enum({limit, enum}) do
    Enum.count_until(enum, fn x -> x > 0 end, limit)
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
