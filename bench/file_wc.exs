path = "/tmp/benched.txt"
File.write!(path, String.duplicate("abcdef\n", 1000))

defmodule Bench do
  # count is optimized, so we also compare manual reduce
  def stream_count(path), do: path |> File.stream!() |> Enum.count()
  def stream_reduce(path), do: path |> File.stream!() |> Enum.reduce(0, fn _, acc -> acc + 1 end)

  def raw_file(path) do
    file_loop(path, [:read, :raw, :binary, :utf8, :read_ahead])
  end

  def no_raw_file(path) do
    file_loop(path, [:read, :binary, :utf8, :read_ahead])
  end

  def no_read_ahead(path) do
    file_loop(path, [:read, :raw, :binary, :utf8])
  end

  defp file_loop(path, opts) do
    {:ok, fd} = :file.open(path, opts)

    try do
      do_file_loop(fd, 0)
    after
      :ok = :file.close(fd)
    end
  end

  defp do_file_loop(fd, acc) do
    case :file.read_line(fd) do
      {:ok, _} -> do_file_loop(fd, acc + 1)
      :eof -> acc
    end
  end
end

Bench.stream_count(path) |> dbg()
Bench.stream_reduce(path) |> dbg()
Bench.raw_file(path) |> dbg()
Bench.no_raw_file(path) |> dbg()
Bench.no_read_ahead(path) |> dbg()

Benchee.run(
  %{
    "File.stream |> Enum.count" => fn -> Bench.stream_count(path) end,
    "File.stream |> Enum.reduce" => fn -> Bench.stream_reduce(path) end,
    ":raw file" => fn -> Bench.raw_file(path) end,
    "no :raw file" => fn -> Bench.no_raw_file(path) end,
    "no :no_read_ahead :raw file" => fn -> Bench.no_read_ahead(path) end
  },
  time: 2,
  memory_time: 0.5
)
