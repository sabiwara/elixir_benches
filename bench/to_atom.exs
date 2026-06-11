defmodule Bench do
  @atoms Enum.map(1..10, &:"foo#{&1}")

  def find(string) do
    Enum.find(@atoms, &(Atom.to_string(&1) == string)) || raise "invalid"
  end

  for atom <- @atoms do
    def match(unquote(Atom.to_string(atom))), do: unquote(atom)
  end

  def atoms, do: @atoms
end

:rand.seed(:exsss, {100, 101, 102})
strings = Bench.atoms() |> Enum.map(&to_string/1) |> Enum.shuffle()

Benchee.run(%{
  "Enum.find" => fn -> Enum.each(strings, &Bench.find/1) end,
  "pattern-matching" => fn -> Enum.each(strings, &Bench.match/1) end,
  "String.to_existing_atom" => fn -> Enum.each(strings, &String.to_existing_atom/1) end
})
