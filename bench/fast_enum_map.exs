list = Enum.to_list(1..100)
fun = &(&1 + 1)

Benchee.run(%{
  "Enum.map/2" => fn -> Enum.map(list, fun) end,
  "FastEnum.map/2" => fn -> FastEnum.map(list, fun) end
})
