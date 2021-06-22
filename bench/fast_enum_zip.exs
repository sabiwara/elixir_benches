list1 = Enum.to_list(1..100)
list2 = Enum.map(list1, & &1 * 2)

Benchee.run(%{
  "Enum.zip/2" => fn -> Enum.zip(list1, list2) end,
  "FastEnum.zip/2" => fn -> FastEnum.zip(list1, list2) end,
  "body recursive" => fn -> FastEnum.zip_list_body(list1, list2) end,
})
