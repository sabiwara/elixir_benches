list = Enum.to_list(1..100)

defmodule Bench do
  def immediately_invoked(list) do
    Enum.reduce(list, [], fn x, acc ->
      y = (fn a -> a + 1 end).(x)
      [y | acc]
    end)
  end

  def manual_inlining(list) do
    Enum.reduce(list, [], fn x, acc ->
      y = x + 1
      [y | acc]
    end)
  end
end

Benchee.run(
  %{
    "IIFE" => fn -> Bench.immediately_invoked(list) end,
    "manual inlining" => fn -> Bench.manual_inlining(list) end
  },
  time: 2
)
