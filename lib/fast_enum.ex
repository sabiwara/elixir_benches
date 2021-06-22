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

  def intersperse(enumerable, element) when is_list(enumerable) do
    case enumerable do
      [] -> []
      list -> intersperse_non_empty_list(list, element)
    end
  end

  def intersperse(enumerable, element) do
    list =
      enumerable
      |> Enum.reduce([], fn x, acc -> [x, element | acc] end)
      |> :lists.reverse()

    # Head is a superfluous intersperser element
    case list do
      [] -> []
      [_ | t] -> t
    end
  end

  def join(enumerable, joiner \\ "")

  def join(enumerable, joiner) when is_list(enumerable) and is_binary(joiner) do
    join_list(enumerable, joiner)
  end

  def join(enumerable, "") do
    enumerable
    |> Enum.map(&entry_to_string(&1))
    |> IO.iodata_to_binary()
  end

  def join(enumerable, joiner) when is_binary(joiner) do
    reduced =
      Enum.reduce(enumerable, :first, fn
        entry, :first -> entry_to_string(entry)
        entry, acc -> [acc, joiner | entry_to_string(entry)]
      end)

    if reduced == :first do
      ""
    else
      IO.iodata_to_binary(reduced)
    end
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

  # scan/2

  def scan(enumerable, fun)

  def scan([], _fun), do: []

  def scan([elem | rest], fun) do
    scanned = scan_list(rest, elem, fun)
    [elem | scanned]
  end

  def scan(enumerable, fun) do
    Enum.scan(enumerable, fun)
  end

  # scan/3

  def scan(enumerable, acc, fun) when is_list(enumerable) do
    scan_list(enumerable, acc, fun)
  end

  def scan(enumerable, acc, fun) do
    Enum.scan(enumerable, acc, fun)
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

  def with_index(enumerable, offset \\ 0)

  def with_index(enumerable, offset) when is_list(enumerable) and is_integer(offset) do
    with_index_list(enumerable, offset)
  end

  def with_index(enumerable, offset) do
    Enum.with_index(enumerable, offset)
  end

  def zip(enumerable1, enumerable2) when is_list(enumerable1) and is_list(enumerable2) do
    zip_lists(enumerable1, enumerable2, [])
  end

  def zip(enumerable1, enumerable2) do
    Enum.zip(enumerable1, enumerable2)
  end

  defp zip_lists(list1, list2, acc) when list1 == [] or list2 == [] do
    :lists.reverse(acc)
  end

  defp zip_lists([head1 | tail1], [head2 | tail2], acc) do
    zip_lists(tail1, tail2, [{head1, head2} | acc])
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

  # intersperse

  defp intersperse_non_empty_list([first], _element), do: [first]

  defp intersperse_non_empty_list([first | rest], element) do
    [first, element | intersperse_non_empty_list(rest, element)]
  end

  # join

  defp join_list([], _separator), do: ""

  defp join_list(list, separator) do
    case separator do
      "" -> do_join_list(list, [])
      _ -> join_non_empty_list(list, separator, [])
    end
    |> :lists.reverse()
    |> IO.iodata_to_binary()
  end

  defp do_join_list([], acc), do: acc

  defp do_join_list([first | rest], acc) do
    do_join_list(rest, [entry_to_string(first) | acc])
  end

  defp join_non_empty_list([first], _element, acc), do: [entry_to_string(first) | acc]

  defp join_non_empty_list([first | rest], element, acc) do
    join_non_empty_list(rest, element, [element, entry_to_string(first) | acc])
  end

  @compile {:inline, entry_to_string: 1}

  defp entry_to_string(entry) when is_binary(entry), do: entry
  defp entry_to_string(entry), do: String.Chars.to_string(entry)

  ## scan

  defp scan_list([], _acc, _fun), do: []

  defp scan_list([elem | rest], acc, fun) do
    acc = fun.(elem, acc)
    [acc | scan_list(rest, acc, fun)]
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

  # with_index

  defp with_index_list(list, offset, acc \\ [])

  @compile {:inline, with_index_list: 3}

  defp with_index_list([], _offset, acc), do: :lists.reverse(acc)

  defp with_index_list([elem | rest], offset, acc) do
    with_index_list(rest, offset + 1, [{elem, offset} | acc])
  end
end
