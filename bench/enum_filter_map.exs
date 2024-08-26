inputs = [
  # "5": Enum.to_list(-5..5),
  "50": Enum.to_list(-50..50),
  "500": Enum.to_list(-500..500)
]

defmodule Bench do
  def comprehension(enum) do
    for x <- enum, x > 0, do: x + 1
  end

  def build_list(enum) do
    build_list(enum, fn x, acc ->
      if x > 0, do: [x + 1 | acc], else: acc
    end)
  end

  def build_list(enum, fun) do
    Enum.reduce(enum, [], fun) |> :lists.reverse()
  end

  def new_flat_map(enum) do
    new_flat_map(enum, fn x ->
      if x > 0, do: [x + 1], else: []
    end)
  end

  defp new_flat_map(list, fun) when is_list(list) and is_function(fun, 1) do
    flat_map_list(list, fun)
  end

  defp flat_map_list([], _fun), do: []

  defp flat_map_list([head | tail], fun) do
    case fun.(head) do
      [] -> flat_map_list(tail, fun)
      [elem] -> [elem | flat_map_list(tail, fun)]
      list when is_list(list) -> list ++ flat_map_list(tail, fun)
      other -> Enum.to_list(other) ++ flat_map_list(tail, fun)
    end
  end

  def flat_map(enum) do
    Enum.flat_map(enum, fn x ->
      if x > 0, do: [x + 1], else: []
    end)
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

# inputs[:"5"] |> Bench.comprehension() |> dbg()
# inputs[:"5"] |> Bench.build_list() |> dbg()
# inputs[:"5"] |> Bench.filter_map() |> dbg()
# inputs[:"5"] |> Bench.flat_map() |> dbg()
# inputs[:"5"] |> Bench.new_flat_map() |> dbg()

Benchee.run(
  %{
    # "comprehension" => &Bench.comprehension/1,
    # "Enum.build_list/2" => &Bench.build_list/1,
    "Enum.filter_map/2" => &Bench.filter_map/1,
    "Enum.flat_map/2" => &Bench.flat_map/1,
    "Enum.new_flat_map/2" => &Bench.new_flat_map/1
  },
  memory_time: 0.5,
  inputs: inputs,
  print: [fast_warning: false]
)
