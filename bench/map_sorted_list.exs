inputs =
  Enum.map([10, 100, 1_000], fn n ->
    {to_string(n), Enum.shuffle(1..n) |> Map.new(&{&1, &1})}
  end)

defmodule Bench do
  def list(map) do
    Map.to_list(map) |> :lists.sort()
  end

  def iterator(map) do
    # added in OTP26
    :maps.iterator(map, :ordered) |> do_iterator([])
  end

  defp do_iterator(iterator, acc) do
    case :maps.next(iterator) do
      :none -> :lists.reverse(acc)
      {k, v, iterator} -> do_iterator(iterator, [{k, v} | acc])
    end
  end
end

Benchee.run(
  %{
    "Map.to_list |> :lists.sort" => &Bench.list(&1),
    "iterator" => &Bench.iterator(&1)
  },
  inputs: inputs,
  memory_time: 0.5
)
