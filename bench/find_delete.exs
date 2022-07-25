defmodule FindDelete do
  # https://elixirforum.com/t/how-to-get-or-remove-the-first-matched-element-in-a-list-without-traverse-it/49128

  def pdict(list, func) do
    list = do_delete_first(list, func)
    {Process.delete(:__delete_first_found__), list}
  end

  defp do_delete_first([], _func), do: []

  defp do_delete_first([head | tail], func) do
    if func.(head) do
      Process.put(:__delete_first_found__, head)
      tail
    else
      [head | do_delete_first(tail, func)]
    end
  end

  def tail_rec(list, fun) when is_function(fun, 1) do
    do_tail_rec(list, fun, [])
  end

  defp do_tail_rec([head | tail], fun, acc) do
    if fun.(head) do
      {head, :lists.reverse(acc, tail)}
    else
      do_tail_rec(tail, fun, [head | acc])
    end
  end

  defp do_tail_rec([], _fun, acc) do
    {nil, :lists.reverse(acc)}
  end
end

list = Enum.to_list(1..100)

{3, [1, 2, 4]} = FindDelete.pdict([1, 2, 3, 4], & &1 == 3)
{3, [1, 2, 4]} = FindDelete.tail_rec([1, 2, 3, 4], & &1 == 3)


Benchee.run(%{
  "process dict" => fn -> FindDelete.pdict(list, & &1 == 50) end,
  "tail recursive" => fn -> FindDelete.tail_rec(list, & &1 == 50) end
}, memory_time: 1)
