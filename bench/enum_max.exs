range = 1..100
list = Enum.to_list(range)

Benchee.run(%{
  ":lists.max/1 (list)" => fn -> :lists.max(list) end,
  "Enum.max/1 (list)" => fn -> Enum.max(list) end
})
