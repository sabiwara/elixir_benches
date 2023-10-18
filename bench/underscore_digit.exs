defmodule Recursive do
  def intersperse(str) do
    length = byte_size(str)
    offset = rem(length, 3)
    {acc, rest} = String.split_at(str, offset)
    do_intersperse(acc, rest)
  end

  defp do_intersperse(acc, ""), do: acc
  defp do_intersperse("", <<next::binary-3, rest::binary>>), do: do_intersperse(next, rest)

  defp do_intersperse(acc, <<next::binary-3, rest::binary>>),
    do: do_intersperse(<<acc::binary, "_", next::binary>>, rest)
end

defmodule Comprehension do
  def intersperse(str) do
    length = byte_size(str)
    offset = rem(length - 1, 3) + 1
    {acc, rest} = String.split_at(str, offset)
    for <<group::binary-3 <- rest>>, into: acc, do: <<"_", group::binary-3>>
  end
end

inputs = Enum.map([7, 30], &{"#{&1} digits", to_string(10 ** &1)})

Benchee.run(
  %{
    Recursive: &Recursive.intersperse/1,
    Comprehension: &Comprehension.intersperse/1
  },
  inputs: inputs,
  memory_time: 0.5
)
