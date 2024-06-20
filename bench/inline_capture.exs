strings = Enum.map(1..10, &"x#{&1}")
_atoms = Enum.map(strings, &String.to_atom/1)

defmodule Bench do
  def not_inlined(strings), do: Enum.each(strings, &String.to_atom/1)
  def inlined(strings), do: Enum.each(strings, &:erlang.binary_to_atom(&1, :utf8))
end

Benchee.run(
  %{
    "not_inlined" => fn -> Bench.not_inlined(strings) end,
    "inlined" => fn -> Bench.inlined(strings) end
  },
  time: 2,
  memory_time: 0.5
)
