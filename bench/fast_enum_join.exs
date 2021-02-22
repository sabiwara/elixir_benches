list = for i <- 1..100, do: to_string(i)

Benchee.run(%{
  "Enum.join/1" => fn -> Enum.join(list) end,
  "Enum.join/2" => fn -> Enum.join(list, ",") end,
  "FastEnum.join/1" => fn -> FastEnum.join(list) end,
  "FastEnum.join/2" => fn -> FastEnum.join(list, ",") end,
})
