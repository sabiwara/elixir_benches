defmodule Bench do
  def regex(string) do
    Regex.run(~r/a/, string)
  end

  def re(string) do
    :re.run(string, ~r/a/.re_pattern, [{:capture, :all, :binary}])
  end

  def version(_string), do: Regex.version()
end

inputs = Enum.map(["matches", "doesn't"], &{&1, &1})

Benchee.run(
  %{
    "Regex.run/2" => &Bench.regex/1,
    ":re.run/3" => &Bench.re/1,
    "Regex.version/0" => &Bench.version/1
  },
  inputs: inputs,
  memory_time: 1
)
