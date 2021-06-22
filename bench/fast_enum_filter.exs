list = Enum.to_list(1..100)
fun = &(rem(&1, 4) == 0)

Benchee.run(%{
  "Enum.filter/2" => fn -> Enum.filter(list, fun) end,
  "FastEnum.filter/2" => fn -> FastEnum.filter(list, fun) end,
})
