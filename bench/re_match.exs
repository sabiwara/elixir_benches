defmodule Bench do
  @email_regex ~r/^[^@,;\s]+@[^@,;\s]+$/

  def email_regex, do: @email_regex

  def valid_email?(string) do
    string =~ @email_regex
  end
end

inputs = [
  valid: "foo@bar.com"
  # invalid: "invalid@email"
]

# reuse same regex ref
regex = Bench.email_regex()

Benchee.run(
  %{
    "import only" => fn _ -> Bench.email_regex() end,
    "match only" => &(&1 =~ regex),
    "import + match" => &Bench.valid_email?/1
  },
  inputs: inputs,
  memory_time: 1
)
