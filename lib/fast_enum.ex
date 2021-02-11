defmodule FastEnum do
  # Proof of concept of faster implementations for `Enum`.

  # instead of using a default `fun \\ fn x -> x end`, define all?/1 and all?/2 separately
  def all?(enumerable)

  def all?(enumerable) when is_list(enumerable) do
    all_list(enumerable)
  end

  def all?(enumerable) do
    Enumerable.reduce(enumerable, {:cont, true}, fn entry, _ ->
      if entry, do: {:cont, true}, else: {:halt, false}
    end)
    |> elem(1)
  end

  # all?/2
  def all?(enumerable, fun)

  def all?(enumerable, fun) when is_list(enumerable) do
    all_list(enumerable, fun)
  end

  def all?(enumerable, fun) do
    Enumerable.reduce(enumerable, {:cont, true}, fn entry, _ ->
      if fun.(entry), do: {:cont, true}, else: {:halt, false}
    end)
    |> elem(1)
  end

  def group_by(enumerable, key_fun) when is_function(key_fun) do
    Enum.reduce(Enum.reverse(enumerable), %{}, fn entry, acc ->
      key = key_fun.(entry)

      case acc do
        %{^key => existing} -> Map.put(acc, key, [entry | existing])
        %{} -> Map.put(acc, key, [entry])
      end
    end)
  end

  def group_by(enumerable, key_fun, value_fun) when is_function(key_fun) do
    Enum.reduce(Enum.reverse(enumerable), %{}, fn entry, acc ->
      key = key_fun.(entry)
      value = value_fun.(entry)

      case acc do
        %{^key => existing} -> Map.put(acc, key, [value | existing])
        %{} -> Map.put(acc, key, [value])
      end
    end)
  end

  def uniq(enumerable) when is_list(enumerable) do
    uniq_list(enumerable, %{})
  end

  def uniq(enumerable) do
    {list, _} =
      Enum.reduce(enumerable, {[], %{}}, fn x, {acc, set} ->
        case set do
          %{^x => _} -> {acc, set}
          _ -> {[x | acc], Map.put(set, x, nil)}
        end
      end)

    :lists.reverse(list)
  end

  ## Implementations

  ## all?/1
  defp all_list([h | t]) do
    if h do
      all_list(t)
    else
      false
    end
  end

  defp all_list([]) do
    true
  end

  # all?/2
  defp all_list([h | t], fun) do
    if fun.(h) do
      all_list(t, fun)
    else
      false
    end
  end

  defp all_list([], _) do
    true
  end

  ## uniq

  defp uniq_list([value | tail], set) do
    case set do
      %{^value => true} -> uniq_list(tail, set)
      %{} -> [value | uniq_list(tail, Map.put(set, value, true))]
    end
  end

  defp uniq_list([], _set) do
    []
  end
end
