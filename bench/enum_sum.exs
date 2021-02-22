range = 1..100
list = Enum.to_list(range)

Benchee.run(%{
  ":lists.sum/1 (list)" => fn -> :lists.sum(list) end,
  "Enum.sum/1 (list)" => fn -> Enum.sum(list) end
})
