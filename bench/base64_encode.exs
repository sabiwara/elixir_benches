inputs =
  Enum.map([32, 128, 512, 1024], fn n ->
    {to_string(n), :crypto.strong_rand_bytes(n)}
  end)

Benchee.run(%{
  "Base.encode64/1" => &Base.encode64/1,
  ":base64.encode/1" => &:base64.encode/1,
}, inputs: inputs, memory_time: 1)
