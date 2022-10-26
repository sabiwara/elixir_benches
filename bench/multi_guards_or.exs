list = Stream.cycle([1, nil, 0, false]) |> Enum.take(100)

Benchee.run(%{
  "for (sum)" => fn ->
    for el <- list, el, reduce: 0 do
      acc -> acc + el
    end
  end,
  "when when (sum)" => fn ->
    Enum.reduce(list, 0, fn el, acc ->
      case el do
        var when var == false when var == nil -> acc
        _ -> acc + el
      end
    end)
  end,
  "when or (sum)" => fn ->
    Enum.reduce(list, 0, fn el, acc ->
      case el do
        var when var == false or var == nil -> acc
        _ -> acc + el
      end
    end)
  end,
  "for (list)" => fn ->
    for el <- list, el, do: el
  end,
  "when when (list)" => fn ->
    Enum.reduce(list, [], fn el, acc ->
      case el do
        var when var == false when var == nil -> acc
        _ -> [el | acc]
      end
    end)
    |> :lists.reverse()
  end,
  "when or (list)" => fn ->
    Enum.reduce(list, [], fn el, acc ->
      case el do
        var when var == false or var == nil -> acc
        _ -> [el | acc]
      end
    end)
    |> :lists.reverse()
  end
})
