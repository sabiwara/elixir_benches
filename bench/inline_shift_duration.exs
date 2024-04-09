Benchee.run(
  %{
    "with Duration struct (inlined)" => fn ->
      Time.shift(~T[20:01:02], %Duration{second: 1})
    end,
    "with keyword" => fn ->
      Time.shift(~T[20:01:02], second: 1)
    end
  },
  memory_time: 0.5
)
