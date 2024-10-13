defmodule Alternative do
  def digits(integer, base \\ 10)
      when is_integer(integer) and is_integer(base) and base >= 2 do
    case integer do
      0 -> [0]
      _integer -> digits(integer, base, [])
    end
  end

  defp digits(0, _base, acc), do: acc

  defp digits(integer, base, acc),
    do: digits(div(integer, base), base, [rem(integer, base) | acc])
end

Benchee.run(
  [
    current: fn -> Integer.digits(123_456_789) end,
    new: fn -> Alternative.digits(123_456_789) end
  ],
  memory_time: 0.5
)
