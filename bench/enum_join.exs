list = Stream.cycle(?a..?z) |> Enum.take(100) |> Enum.map(fn i -> <<i>> end)

defmodule Bench do
  def join(enum) do
    do_join(enum, "")
  end

  defp do_join([], acc), do: acc
  defp do_join([x | xs], acc), do: do_join(xs, acc <> x)

  def join(enum, sep) when is_binary(sep) do
    case enum do
      [] -> ""
      [x | xs] -> do_join(xs, sep, x)
    end
  end

  defp do_join([], _sep, acc), do: acc
  defp do_join([x | xs], sep, acc), do: do_join(xs, sep, acc <> sep <> x)
end

Benchee.run(
  %{
    "new" => fn -> Bench.join(list) end,
    "Enum" => fn -> Enum.join(list) end,
    "new sep" => fn -> Bench.join(list, ",") end,
    "Enum sep" => fn -> Enum.join(list, ",") end
  },
  memory_time: 1,
  reduction_time: 1
)
