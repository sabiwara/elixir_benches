list = Enum.to_list(1..100)

Benchee.run(%{
  "Enum.scan/2" => fn -> Enum.scan(list, &+/2) end,
  "Enum.scan/3" => fn -> Enum.scan(list, 0, &+/2) end,
  "FastEnum.scan/2" => fn -> FastEnum.scan(list, &+/2) end,
  "FastEnum.scan/3" => fn -> FastEnum.scan(list, 0, &+/2) end
})
