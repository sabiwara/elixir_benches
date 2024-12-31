ten_obj = Enum.map(1..10, &%{"foo#{&1}" => "\0"})

Benchee.run(
  [
    # "json iodata": &:erl_json.encode/1,
    # "faster iodata": &:faster_json.encode/1,
    "json binary": &IO.iodata_to_binary(:erl_json.encode(&1)),
    "faster binary": &IO.iodata_to_binary(:faster_json.encode(&1))
  ],
  inputs: [{"10 objects", ten_obj}],
  memory_time: 0.5
)
