list = Enum.to_list(1..100)

Benchee.run(%{
  "Enum.with_index/2 (offset)" => fn -> Enum.with_index(list) end,
  "FastEnum.with_index/2 (offset)" => fn -> FastEnum.with_index(list) end,
  "Enum.with_index/2 (fun)" => fn -> Enum.with_index(list, &{&2, &1}) end,
  "FastEnum.with_index/2 (fun)" => fn -> FastEnum.with_index(list, &{&2, &1}) end
})
