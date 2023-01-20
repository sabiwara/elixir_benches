list = Enum.to_list(1..100)

defmodule Bench do
  @compile :inline_list_funcs
  def enum_map(list), do: Enum.map(list, &(&1 + 1))
  def list_map(list), do: :lists.map(&(&1 + 1), list)
end

Benchee.run(%{
  "Enum.map" => fn -> Bench.enum_map(list) end,
  "inlined :lists.map" => fn -> Bench.list_map(list) end,
  "erlang comprehension" => fn -> :erl_map.comprehension(list) end,
  "recursive anonymous" => fn -> :erl_map.anonymous(list) end,
  "maybe erlang comprehension" => fn -> :erl_map.comprehension_case(list) end,
  "maybe recursive anonymous" => fn -> :erl_map.anonymous_case(list) end
})
