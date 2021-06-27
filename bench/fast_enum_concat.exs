range = 1..1000
list_inputs = Enum.map [1, 10, 100, 1000], fn chunk_size ->
  list = Enum.chunk_every(range, chunk_size)
  name = "#{length(list)} chunks of #{chunk_size} elements (list)"
  {name, list}
end

range_inputs =  Enum.map [10, 100], fn chunk_size ->
  chunk_count = div(1000, chunk_size)
  set = MapSet.new(0..(chunk_count - 1), fn i ->
     start = 1 + (i * chunk_size)
    last = start + chunk_size - 1
     start..last
  end)
  name = "#{chunk_count} chunks of #{chunk_size} elements (enumerables)"
  {name, set}
end

inputs = list_inputs ++ range_inputs

Benchee.run(%{
  "Enum.concat/1" => &Enum.concat/1,
  "FastEnum.concat/1" => &FastEnum.concat/1,
}, inputs: inputs)
