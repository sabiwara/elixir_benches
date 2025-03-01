inputs =
  Enum.map([{50, 10}, {2000, 10}, {50, 100}, {2000, 100}], fn {n, size} ->
    {"#{n}x#{size}",
     Stream.cycle(?a..?z)
     |> Stream.chunk_every(size)
     |> Stream.map(&List.to_string/1)
     |> Enum.take(n)}
  end)

defmodule Bench do
  def concat_string(enum) do
    Enum.reduce(enum, "", &(&2 <> &1))
  end

  def concat_iodata(enum) do
    Enum.reduce(enum, [], &[&2 | &1]) |> IO.iodata_to_binary()
  end

  def concat_reverse_list(enum) do
    Enum.reduce(enum, [], &[&1 | &2]) |> :lists.reverse() |> IO.iodata_to_binary()
  end
end

# letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
# Bench.concat_string(letters) |> dbg()
# Bench.concat_iodata(letters) |> dbg()
# Bench.concat_reverse_list(letters) |> dbg()

Benchee.run(
  [
    concat_string: &Bench.concat_string/1,
    concat_iodata: &Bench.concat_iodata/1,
    concat_reverse_list: &Bench.concat_reverse_list/1
  ],
  inputs: inputs,
  memory_time: 0.5
)
