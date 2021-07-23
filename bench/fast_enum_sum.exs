list = List.duplicate(1, 100)

Benchee.run(%{
  "Enum.sum/1" => fn -> Enum.sum(list) end,
  "FastEnum.sum/1" => fn -> FastEnum.sum(list) end
})
