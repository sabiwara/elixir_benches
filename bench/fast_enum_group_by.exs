range = 1..100
list = Enum.to_list(range)
fun = fn x -> rem(x, 10) end

Benchee.run(%{
  "Enum.group_by/2 (list)" => fn -> Enum.group_by(list, fun) end,
  "Enum.group_by/2 (range)" => fn -> Enum.group_by(range, fun) end,
  "FastEnum.group_by/2 (list)" => fn -> FastEnum.group_by(list, fun) end,
  "FastEnum.group_by/2 (range)" => fn -> FastEnum.group_by(range, fun) end
})
