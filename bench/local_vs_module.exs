defmodule Bench do
  # uncomment to get S file
  # @compile :S

  def module(enum) do
    Enum.each(enum, &__MODULE__.foo/1)
  end

  def local(enum) do
    Enum.each(enum, &foo/1)
  end

  def local_closure, do: &foo/1
  def remote_closure, do: &__MODULE__.foo/1

  def foo(x), do: 1 + x
end

inputs = [
  {"list", Enum.to_list(1..1000)}
]

local_closure = Bench.local_closure()
remote_closure = Bench.remote_closure()

Benchee.run(
  [
    module: &Bench.module/1,
    local: &Bench.local/1,
    local_closure: &Enum.each(&1, local_closure),
    remote_closure: &Enum.each(&1, remote_closure)
  ],
  inputs: inputs
)
