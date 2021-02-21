list = Enum.to_list(1..100)

Benchee.run(%{
  "Enum.intersperse/2" => fn -> Enum.intersperse(list, nil) end,
  "FastEnum.intersperse/2" => fn -> FastEnum.intersperse(list, nil) end
})
