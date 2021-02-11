range = 1..100
list = Enum.to_list(range)
dup_list = List.duplicate(1, Enum.count(range))

Benchee.run(%{
  "Enum.uniq/1 (list)" => fn -> Enum.uniq(list) end,
  "Enum.uniq/1 (dup_list)" => fn -> Enum.uniq(dup_list) end,
  "Enum.uniq/1 (range)" => fn -> Enum.uniq(range) end,
  "FastEnum.uniq/1 (list)" => fn -> FastEnum.uniq(list) end,
  "FastEnum.uniq/1 (dup_list)" => fn -> FastEnum.uniq(dup_list) end,
  "FastEnum.uniq/1 (range)" => fn -> FastEnum.uniq(range) end
})
