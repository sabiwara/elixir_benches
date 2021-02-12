defmodule RandString1 do
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def string_of_length(length) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end
end

defmodule RandString2 do
  @char_offset ?A - 1

  def string_of_length(length) do
    do_string_of_length(length, [])
  end

  defp do_string_of_length(_length = 0, acc), do: IO.iodata_to_binary(acc)

  defp do_string_of_length(length, acc) do
    do_string_of_length(length - 1, [(:rand.uniform(26) + @char_offset) | acc])
  end
end

RandString1.string_of_length(10) |> IO.inspect(label: "one")
RandString2.string_of_length(10) |> IO.inspect(label: "two")

Benchee.run(%{
  "RandString1" => fn -> RandString1.string_of_length(10) end,
  "RandString2" => fn -> RandString2.string_of_length(10) end
})
