range = 1..100
list = Enum.to_list(range)

Benchee.run(%{
  "Enum.all?/1 (list)" => fn -> Enum.all?(list) end,
  "Enum.all?/1 (range)" => fn -> Enum.all?(range) end,
  "FastEnum.all?/1 (list)" => fn -> FastEnum.all?(list) end,
  "FastEnum.all?/1 (range)" => fn -> FastEnum.all?(range) end
})
