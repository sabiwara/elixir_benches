defmodule Foo do
  def foo(x), do: 1 + x
end

defmodule Bench do
  # uncomment to get S file
  # @compile :S

  def module(enum) do
    Enum.each(enum, &Foo.foo/1)
  end

  def local(enum) do
    Enum.each(enum, &foo/1)
  end

  def foo(x), do: 1 + x
end

inputs = [
  {"list", Enum.to_list(1..1000)}
]

Benchee.run(
  [
    module: &Bench.module/1,
    local: &Bench.local/1
  ],
  inputs: inputs
)
