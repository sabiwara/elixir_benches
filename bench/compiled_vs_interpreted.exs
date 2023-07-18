list = Enum.to_list(1..100)

defmodule Compiled do
  def comprehension(list) do
    for x <- list, rem(x, 2) == 1, do: x + 1
  end
end

Benchee.run(
  %{
    "compiled" => fn -> Compiled.comprehension(list) end,
    "interpreted" => fn -> for x <- list, rem(x, 2) == 1, do: x + 1 end
  },
  memory_time: 0.5
)
