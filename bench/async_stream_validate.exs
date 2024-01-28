# Benchmarking the impact of adding validation to async_stream options
# and various implementations for it.
# https://github.com/elixir-lang/elixir/pull/13289

defmodule Bench do
  def validate_keyword(options) do
    options =
      Keyword.validate!(options,
        max_concurrency: System.schedulers_online(),
        on_timeout: :exit,
        timeout: 5000,
        ordered: true,
        zip_input_on_exit: false,
        shutdown: 5000
      )

    max_concurrency = options[:max_concurrency]
    timeout = options[:timeout]
    shutdown = options[:shutdown]

    unless is_integer(max_concurrency) and max_concurrency > 0 do
      raise ArgumentError, ":max_concurrency must be an integer greater than zero"
    end

    unless options[:on_timeout] in [:exit, :kill_task] do
      raise ArgumentError, ":on_timeout must be either :exit or :kill_task"
    end

    unless (is_integer(timeout) and timeout >= 0) or timeout == :infinity do
      raise ArgumentError, ":timeout must be either a positive integer or :infinity"
    end

    unless (is_integer(shutdown) and shutdown >= 0) or shutdown == :brutal_kill do
      raise ArgumentError, ":shutdown must be either a positive integer or :brutal_kill"
    end

    options
  end

  def validate_tuple(options) do
    max_concurrency = Keyword.get(options, :max_concurrency, System.schedulers_online())
    on_timeout = Keyword.get(options, :on_timeout, :exit)
    timeout = Keyword.get(options, :timeout, 5000)
    ordered = Keyword.get(options, :ordered, true)
    zip_input_on_exit = Keyword.get(options, :zip_input_on_exit, false)
    shutdown = Keyword.get(options, :shutdown, 5000)

    unless is_integer(max_concurrency) and max_concurrency > 0 do
      raise ArgumentError, ":max_concurrency must be an integer greater than zero"
    end

    unless on_timeout in [:exit, :kill_task] do
      raise ArgumentError, ":on_timeout must be either :exit or :kill_task"
    end

    unless (is_integer(timeout) and timeout >= 0) or timeout == :infinity do
      raise ArgumentError, ":timeout must be either a positive integer or :infinity"
    end

    unless (is_integer(shutdown) and shutdown >= 0) or shutdown == :brutal_kill do
      raise ArgumentError, ":shutdown must be either a positive integer or :brutal_kill"
    end

    {max_concurrency, on_timeout, timeout, ordered, zip_input_on_exit, shutdown}
  end

  @options [:max_concurrency, :on_timeout, :timeout, :ordered, :zip_input_on_exit, :shutdown]

  def check_unknown_keys(options) do
    extra_keys = for {key, _} when key not in @options <- options, do: key

    if extra_keys != [] do
      IO.warn("unknown option: #{inspect(extra_keys)}")
    end
  end

  def check_unknown_and_duplicate_keys(options) do
    extra_keys = Keyword.keys(options) -- @options

    if extra_keys != [] do
      IO.warn("unknown option: #{inspect(extra_keys)}")
    end
  end

  def validate_map(options) do
    max_concurrency = Keyword.get(options, :max_concurrency, System.schedulers_online())
    on_timeout = Keyword.get(options, :on_timeout, :exit)
    timeout = Keyword.get(options, :timeout, 5000)
    ordered = Keyword.get(options, :ordered, true)
    zip_input_on_exit = Keyword.get(options, :zip_input_on_exit, false)
    shutdown = Keyword.get(options, :shutdown, 5000)

    unless is_integer(max_concurrency) and max_concurrency > 0 do
      raise ArgumentError, ":max_concurrency must be an integer greater than zero"
    end

    unless on_timeout in [:exit, :kill_task] do
      raise ArgumentError, ":on_timeout must be either :exit or :kill_task"
    end

    unless (is_integer(timeout) and timeout >= 0) or timeout == :infinity do
      raise ArgumentError, ":timeout must be either a positive integer or :infinity"
    end

    unless (is_integer(shutdown) and shutdown >= 0) or shutdown == :brutal_kill do
      raise ArgumentError, ":shutdown must be either a positive integer or :brutal_kill"
    end

    %{
      max_concurrency: max_concurrency,
      on_timeout: on_timeout,
      timeout: timeout,
      ordered: ordered,
      zip_input_on_exit: zip_input_on_exit,
      shutdown: shutdown
    }
  end

  def run_stream(options) do
    [1, 2, 3]
    |> Task.async_stream(& &1, options)
    |> Enum.map(fn {:ok, res} -> res end)
  end
end

options = [ordered: false, timeout: 10]

Benchee.run(
  [
    {"Validate (return Keyword)", fn -> Bench.validate_keyword(options) end},
    {"Validate (return Tuple)", fn -> Bench.validate_tuple(options) end},
    {"Validate (return Map)", fn -> Bench.validate_map(options) end},
    {"Validate+check unknown keys (using Map)",
     fn ->
       Bench.check_unknown_keys(options)
       Bench.validate_map(options)
     end},
    {"Validate+check unknown & duplicate keys (using Map)",
     fn ->
       Bench.check_unknown_and_duplicate_keys(options)
       Bench.validate_map(options)
     end},
    {"Run stream", fn -> Bench.run_stream(options) end},
    {"Validate + Run stream (using Keyword)",
     fn -> Bench.validate_keyword(options) |> Bench.run_stream() end}
  ],
  memory_time: 0.5
)
