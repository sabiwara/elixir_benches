inputs =
  Enum.map([100, 10_000, 1_000_000], fn n ->
    {to_string(n), Enum.shuffle(1..n)}
  end)

defmodule Bench do
  def sort(list, :desc) do
    :lists.sort(list) |> :lists.reverse()
  end
end

Benchee.run(
  %{
    "|> Enum.sort(:desc)" => &Enum.sort(&1, :desc),
    "|> :lists.sort |> :lists.reverse" => &Bench.sort(&1, :desc)
  },
  inputs: inputs,
  memory_time: 0.5
)
