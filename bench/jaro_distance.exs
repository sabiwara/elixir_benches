inputs =
  Enum.map([1, 10, 100], fn n ->
    {n, {String.duplicate("Saturday", n), String.duplicate("Sunday", n)}}
  end)

Benchee.run(
  %{
    "String.jaro_distance/2" => fn {left, right} -> String.jaro_distance(left, right) end,
    ":string.jaro_similarity/2" => fn {left, right} -> :string.jaro_similarity(left, right) end
  },
  inputs: inputs,
  memory_time: 0.5
)
