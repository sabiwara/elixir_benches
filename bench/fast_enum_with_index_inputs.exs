inputs = for n <- [10, 100, 1000, 10_000, 100_000] do
  list = Enum.to_list(1..n)
  {to_string(n), list}
end

Benchee.run(
  %{
    "Enum.with_index/2" => &Enum.with_index/1,
    "FastEnum.with_index/2" => &FastEnum.with_index/1,
    "FastEnum.with_index_body_rec/2" => &FastEnum.with_index_body_rec/1
  },
  inputs: inputs,
  memory_time: 1,
  # fast for small inputs
  print: [fast_warning: false]
)
