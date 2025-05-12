inputs = [
  "5 in 50": {5, Enum.to_list(0..50)},
  "5 in 500": {5, Enum.to_list(0..500)},
  "1000 in 500": {1000, Enum.to_list(0..500)}
]

defmodule Optimized do
  def count_until(enumerable, limit) when is_integer(limit) and limit > 0 do
    case enumerable do
      list when is_list(list) -> count_until_list(list, limit, 0)
      _ -> count_until_enum(enumerable, limit)
    end
  end

  @compile {:inline, count_until_list: 3}

  defp count_until_list([], _limit, acc), do: acc

  defp count_until_list([_head | tail], limit, acc) do
    case acc + 1 do
      ^limit -> limit
      acc -> count_until_list(tail, limit, acc)
    end
  end

  defp count_until_enum(enumerable, limit) do
    Enumerable.reduce(enumerable, {:cont, 0}, fn _entry, acc ->
      case acc + 1 do
        ^limit -> {:halt, limit}
        acc -> {:cont, acc}
      end
    end)
    |> elem(1)
  end
end

defmodule Bench do
  def optimized({limit, enum}) do
    Optimized.count_until(enum, limit)
  end

  def enum({limit, enum}) do
    Enum.count_until(enum, limit)
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
