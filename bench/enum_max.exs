range = 1..100
list = Enum.to_list(range)

Benchee.run(%{
  ":lists.max/1 (list)" => fn -> :lists.max(list) end,
  "Enum.max/1 (list)" => fn -> Enum.max(list) end,
  "FastEnum.max/1 (list)" => fn -> FastEnum.max(list) end,
  "FastEnum.max/2 (list with fallback)" => fn -> FastEnum.max(list, fn -> 0 end) end,
})
