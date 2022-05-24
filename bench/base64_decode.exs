inputs =
  Enum.map([32, 128, 512, 1024], fn n ->
    {to_string(n), :crypto.strong_rand_bytes(n) |> Base.encode64()}
  end)

Benchee.run(%{
  "Base.decode64/1" => &Base.decode64/1,
  ":base64.decode/1" => &:base64.decode/1,
}, inputs: inputs, memory_time: 1)
