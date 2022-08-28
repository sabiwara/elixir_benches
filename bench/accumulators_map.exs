inputs =
  Enum.map([100, 1000, 10_000], fn n ->
    {n, Enum.to_list(1..n)}
  end)

Benchee.run(
  %{
    "reduce" => fn list ->
      Enum.reduce(list, %{}, &Map.put(&2, &1, &1))
    end,
    "Agents (agent-side)" => fn list ->
      {:ok, pid} = Agent.start(fn -> %{} end)

      Enum.each(list, fn el ->
        :ok = Agent.update(pid, &Map.put(&1, el, el))
      end)

      result = Agent.get(pid, & &1)
      # Ensure we do not leak processes
      Agent.stop(pid)
      result
    end,
    "Agents (client-side)" => fn list ->
      {:ok, pid} = Agent.start(fn -> %{} end)

      Enum.each(list, fn el ->
        acc = Agent.get(pid, & &1)
        acc = Map.put(acc, el, el)
        :ok = Agent.update(pid, fn _ -> acc end)
      end)

      result = Agent.get(pid, & &1)
      # Ensure we do not leak processes
      Agent.stop(pid)
      result
    end,
    "Process dict" => fn list ->
      :erlang.put({__MODULE__, :acc}, %{})

      Enum.each(list, fn el ->
        acc = :erlang.get({__MODULE__, :acc})
        acc = Map.put(acc, el, el)
        :erlang.put({__MODULE__, :acc}, acc)
      end)

      # Ensure we do not leak memory
      result = :erlang.put({__MODULE__, :acc}, :undefined)
      result
    end,
    "ETS" => fn list ->
      :ets.new(:acculators, [:named_table, :set, :public, write_concurrency: :auto])
      :ets.insert(:acculators, {:acc, %{}})

      Enum.each(list, fn el ->
        acc = :ets.lookup_element(:acculators, :acc, 2)
        acc = Map.put(acc, el, el)
        :ets.update_element(:acculators, :acc, {2, acc})
      end)

      result = :ets.lookup_element(:acculators, :acc, 2)
      # Ensure we do not leak memory
      :ets.delete(:acculators)
      result
    end
  },
  inputs: inputs,
  memory_time: 0.5
)
