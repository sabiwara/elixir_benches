range = 1..100
list = Enum.to_list(range)
dup_list = List.duplicate(1, Enum.count(range))

Benchee.run(%{
  "Enum.dedup/1 (list)" => fn -> Enum.dedup(list) end,
  "Enum.dedup/1 (dup_list)" => fn -> Enum.dedup(dup_list) end,
  "Enum.dedup/1 (range)" => fn -> Enum.dedup(range) end,
  "FastEnum.dedup/1 (list)" => fn -> FastEnum.dedup(list) end,
  "FastEnum.dedup/1 (dup_list)" => fn -> FastEnum.dedup(dup_list) end,
  "FastEnum.dedup/1 (range)" => fn -> FastEnum.dedup(range) end
})
