defmodule Bench do
  @atoms Enum.map(1..10, &:"foo#{&1}")

  def find(string) do
    Enum.find(@atoms, &(Atom.to_string(&1) == string)) || raise "invalid"
  end

  def member(string) do
    atom = String.to_existing_atom(string)

    if not Enum.member?(@atoms, atom) do
      raise "invalid"
    end

    atom
  end

  for atom <- @atoms do
    def match(unquote(Atom.to_string(atom))), do: unquote(atom)
  end

  def match(_), do: raise("invalid")

  @lookup_map Map.new(@atoms, &{Atom.to_string(&1), &1})
  def map_get(string) do
    Map.get(@lookup_map, string) || raise "invalid"
  end

  def atoms, do: @atoms
end

:rand.seed(:exsss, {100, 101, 102})
strings = Bench.atoms() |> Enum.map(&to_string/1) |> Enum.shuffle()

Benchee.run(%{
  "Enum.find" => fn -> Enum.each(strings, &Bench.find/1) end,
  "Enum.member?" => fn -> Enum.each(strings, &Bench.member/1) end,
  "pattern-matching" => fn -> Enum.each(strings, &Bench.match/1) end,
  "Map.get" => fn -> Enum.each(strings, &Bench.map_get/1) end,
  "String.to_existing_atom" => fn -> Enum.each(strings, &String.to_existing_atom/1) end
})
