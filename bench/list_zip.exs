inputs =
  for length <- [10, 100], count <- [10, 100] do
    {"#{count} * #{length}", Enum.chunk_every(1..(length * count), length)}
  end

Benchee.run(
  %{
    "List.zip/1" => &List.zip/1,
    "Enum.zip/1" => &Enum.zip/1
  },
  memory_time: 0.5,
  inputs: inputs
)
