defmodule Bench do
  # https://github.com/ex-aws/ex_aws/blob/b3414592abddb88ba849359dbc51d360a4bd3b11/lib/ex_aws/config/defaults.ex#L113-L129

  def enum_find_run(region) do
    Enum.find(partitions(), fn {regex, _} ->
      Regex.run(regex, region)
    end)
  end

  def enum_find_match(region) do
    Enum.find(partitions(), fn {regex, _} ->
      region =~ regex
    end)
  end

  defp partitions(),
    do: [
      {~r/^(us|eu|af|ap|sa|ca|me)\-\w+-\d?-?\w+$/, "aws"},
      {~r/^cn\-\w+\-\d+$/, "aws-cn"},
      {~r/^us\-gov\-\w+\-\d+$/, "aws-us-gov"}
    ]

  def cond_match(region) do
    cond do
      region =~ ~r/^(us|eu|af|ap|sa|ca|me)\-\w+-\d?-?\w+$/ -> "aws"
      region =~ ~r/^cn\-\w+\-\d+$/ -> "aws-cn"
      region =~ ~r/^us\-gov\-\w+\-\d+$/ -> "aws-us-gov"
      true -> nil
    end
  end
end

inputs = Enum.map(["us-east-2", "us-gov-east-1"], &{&1, &1})

Benchee.run(
  %{
    "Enum.find + Regex.run" => &Bench.enum_find_run/1,
    "Enum.find + =~" => &Bench.enum_find_match/1,
    "cond + =~" => &Bench.cond_match/1
  },
  inputs: inputs,
  memory_time: 1
)
