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

  def dedup(enumerable) when is_list(enumerable) do
    dedup_list(enumerable, []) |> :lists.reverse()
  end

  def dedup(enumerable) do
    Enum.reduce(enumerable, [], fn x, acc ->
      case acc do
        [^x, _] -> acc
        _ -> [x | acc]
      end
    end)
    |> :lists.reverse()
  end

  def max(list = [_ | _]) do
    :lists.max(list)
  end

  def max(list = [_ | _], empty_fallback) when is_function(empty_fallback, 0) do
    :lists.max(list)
  end

  def max(enumerable, empty_fallback) when is_function(empty_fallback, 0) do
    max(enumerable, &>=/2, empty_fallback)
  end

  def max(enumerable, sorter \\ &>=/2, empty_fallback \\ fn -> raise Enum.EmptyError end) do
    aggregate(enumerable, max_sort_fun(sorter), empty_fallback)
  end

  defp max_sort_fun(sorter) when is_function(sorter, 2), do: sorter
  defp max_sort_fun(module) when is_atom(module), do: &(module.compare(&1, &2) != :lt)

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

  # min/max

  defp aggregate([head | tail], fun, _empty) do
    aggregate_list(tail, head, fun)
  end

  defp aggregate([], _fun, empty) do
    empty.()
  end

  defp aggregate(first..last, fun, _empty) do
    case fun.(first, last) do
      true -> first
      false -> last
    end
  end

  defp aggregate(enumerable, fun, empty) do
    ref = make_ref()

    enumerable
    |> Enum.reduce(ref, fn
      element, ^ref ->
        element

      element, acc ->
        case fun.(acc, element) do
          true -> acc
          false -> element
        end
    end)
    |> case do
      ^ref -> empty.()
      result -> result
    end
  end

  defp aggregate_list([head | tail], acc, fun) do
    acc =
      case fun.(acc, head) do
        true -> acc
        false -> head
      end

    aggregate_list(tail, acc, fun)
  end

  defp aggregate_list([], acc, _fun), do: acc

  ## dedup

  defp dedup_list([value | tail], acc) do
    acc =
      case acc do
        [^value | _] -> acc
        _ -> [value | acc]
      end

    dedup_list(tail, acc)
  end

  defp dedup_list([], acc) do
    acc
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