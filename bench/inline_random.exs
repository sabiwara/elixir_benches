inputs = Enum.map([10, 100, 1_000], fn n -> {n, n} end)

defmodule Bench do
  @atoms_1000 Enum.map(1..1000, &:"x#{&1}")
  @atoms_100 Enum.take(@atoms_1000, 100)
  @atoms_10 Enum.take(@atoms_1000, 10)

  def random(10), do: Enum.random(@atoms_10)
  def random(100), do: Enum.random(@atoms_100)
  def random(1000), do: Enum.random(@atoms_1000)

  defmacrop inline_random(ast) do
    list = Macro.expand(ast, __CALLER__)

    quote do
      :erlang.element(:rand.uniform(unquote(length(list))), {unquote_splicing(list)})
    end
  end

  def optimized(10), do: inline_random(@atoms_10)
  def optimized(100), do: inline_random(@atoms_100)
  def optimized(1000), do: inline_random(@atoms_1000)
end

Benchee.run(
  %{
    "non-optimized" => &Bench.random/1,
    "optimized" => &Bench.optimized/1
  },
  inputs: inputs,
  memory_time: 0.5
)
