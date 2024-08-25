inputs = [
  "5": Enum.to_list(-5..5),
  "50": Enum.to_list(-50..50)
]

defmodule Bench do
  def find_value(enum) do
    Enum.find_value(enum, fn x ->
      if x > 0, do: x + 1
    end)
  end

  def find_map(enum) do
    find_map(enum, fn x ->
      if x > 0, do: {:ok, x + 1}, else: :error
    end)
  end

  def find_map(enum, fun) when is_list(enum) and is_function(fun, 1) do
    do_find_map(enum, fun)
  end

  defp do_find_map([], _fun), do: :error

  defp do_find_map([x | xs], fun) do
    case fun.(x) do
      {:ok, y} -> {:ok, y}
      :error -> do_find_map(xs, fun)
    end
  end
end

Benchee.run(
  %{
    "Enum.find_value/2" => &Bench.find_value/1,
    "Enum.find_map/2" => &Bench.find_map/1
  },
  memory_time: 0.5,
  inputs: inputs,
  print: [fast_warning: false]
)
