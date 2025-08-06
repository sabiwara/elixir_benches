defmodule MyKernel do
  defmacro my_if(condition, clauses) do
    build_if(condition, clauses)
  end

  defp build_if(condition, do: do_clause) do
    build_if(condition, do: do_clause, else: nil)
  end

  defp build_if(condition, do: do_clause, else: else_clause) do
    annotate_case(
      [optimize_boolean: true, type_check: :expr],
      quote do
        case unquote(condition) do
          x when :erlang.==(x, false) or :erlang.==(x, nil) -> unquote(else_clause)
          _ -> unquote(do_clause)
        end
      end
    )
  end

  defp build_if(_condition, _arguments) do
    raise ArgumentError,
          "invalid or duplicate keys for if, only \"do\" and an optional \"else\" are permitted"
  end

  defp annotate_case(extra, {:case, meta, args}) do
    {:case, extra ++ meta, args}
  end
end

defmodule CopiedKernel do
  defmacro copied_if(condition, clauses) do
    build_if(condition, clauses)
  end

  defp build_if(condition, do: do_clause) do
    build_if(condition, do: do_clause, else: nil)
  end

  defp build_if(condition, do: do_clause, else: else_clause) do
    annotate_case(
      [optimize_boolean: true, type_check: :expr],
      quote do
        case unquote(condition) do
          x when :"Elixir.Kernel".in(x, [false, nil]) -> unquote(else_clause)
          _ -> unquote(do_clause)
        end
      end
    )
  end

  defp build_if(_condition, _arguments) do
    raise ArgumentError,
          "invalid or duplicate keys for if, only \"do\" and an optional \"else\" are permitted"
  end

  defp annotate_case(extra, {:case, meta, args}) do
    {:case, extra ++ meta, args}
  end
end

defmodule Bench do
  import CopiedKernel
  import MyKernel

  def expand_kernel() do
    ast =
      quote do
        if Enum.random([true, false]), do: 1, else: 0
      end

    expand(ast)
  end

  def expand_copied() do
    ast =
      quote do
        copied_if(Enum.random([true, false]), do: 1, else: 0)
      end

    expand(ast)
  end

  def expand_new() do
    ast =
      quote do
        my_if(Enum.random([true, false]), do: 1, else: 0)
      end

    expand(ast)
  end

  def expand(ast) do
    ast |> :elixir_expand.expand(:elixir_env.env_to_ex(__ENV__), __ENV__) |> elem(0)
  end
end

Bench.expand_kernel() |> dbg()
Bench.expand_new() |> dbg()

Benchee.run(
  [
    copied: &Bench.expand_copied/0,
    new: &Bench.expand_new/0,
    kernel: &Bench.expand_kernel/0
  ],
  time: 3
)
