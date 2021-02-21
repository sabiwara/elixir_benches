list = Enum.to_list(1..100)

Benchee.run(%{
  "Enum.with_index/2" => fn -> Enum.with_index(list) end,
  "FastEnum.with_index/2" => fn -> FastEnum.with_index(list) end
})
