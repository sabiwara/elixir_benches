range = 1..50
key = 25
map = Map.new(range, &{&1, &1})

Benchee.run(%{
  "Map.get/1" => fn -> Map.get(map, key) end,
  "Map.fetch/1" => fn -> Map.fetch(map, key) end,
  "Map.fetch!/1" => fn -> Map.fetch!(map, key) end,
  "map[key] access" => fn -> map[key] end,
  "pattern matching" => fn ->
    case map do
      %{^key => value} -> value
      %{} -> nil
    end
  end,
}, print: [fast_warning: false])
