inputs = [
  "5": Enum.to_list(-5..5),
  "50": Enum.to_list(-50..50),
  "500": Enum.to_list(-500..500)
]

defmodule Bench do
  def comprehension(enum) do
    for x <- enum, x > 0, do: x + 1
  end

  def filter_map(enum) do
    filter_map(enum, fn x ->
      if x > 0, do: {:ok, x + 1}, else: :error
    end)
  end

  def filter_map(enum, fun) when is_list(enum) and is_function(fun, 1) do
    do_filter_map(enum, fun)
  end

  defp do_filter_map([], _fun), do: []

  defp do_filter_map([x | xs], fun) do
    case fun.(x) do
      {:ok, y} -> [y | do_filter_map(xs, fun)]
      :error -> do_filter_map(xs, fun)
    end
  end
end

inputs[:"5"] |> Bench.comprehension() |> dbg()
inputs[:"5"] |> Bench.filter_map() |> dbg()

Benchee.run(
  %{
    "Enum.comprehension/2" => &Bench.comprehension/1,
    "Enum.filter_map/2" => &Bench.filter_map/1
  },
  memory_time: 0.5,
  inputs: inputs,
  print: [fast_warning: false]
)
