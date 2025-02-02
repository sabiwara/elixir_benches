inputs =
  Enum.map([5, 20, 100], fn n ->
    {"size=#{n}", Enum.shuffle(1..n//1)}
  end)

Benchee.run(
  %{
    ":lists.sort" => &:lists.sort/1,
    ":lists.usort" => &:lists.usort/1,
    "Enum.uniq" => &Enum.uniq/1,
    ":lists.uniq" => &:lists.uniq/1,
    "MapSet.new" => &MapSet.new/1
  },
  memory_time: 0.5,
  inputs: inputs
)
