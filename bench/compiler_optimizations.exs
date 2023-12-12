list = Enum.to_list(1..100)

defmodule Compiled do
  def comprehension(list) do
    for x <- list, rem(x, 2) == 1, do: x + 1
  end
end

# Top level definitions used to be slower than module definitions.
# These were due to disabled compiler optimizations (no_bool_opt, no_ssa_opt)
# and have been fixed from elixir 1.16.0-rc.1:
# https://github.com/elixir-lang/elixir/commit/aabe46536e021da88de39bc5c82c90d97b0604ec#diff-1f4ed234972cb699fe6dc400f3bbf57f72919ef587ba6b1a43441c8b784b0cfb

Benchee.run(%{
  "module (optimized)" => fn -> Compiled.comprehension(list) end,
  "top_level (non-optimized)" => fn -> for x <- list, rem(x, 2) == 1, do: x + 1 end
})
