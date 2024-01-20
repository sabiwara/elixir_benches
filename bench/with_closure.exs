inputs = Enum.to_list(1..100)

Benchee.run(
  [
    no_closure: fn ->
      Enum.reduce(inputs, 0, fn n, _acc ->
        case n do
          i when rem(i, 2) == 0 ->
            case i do
              j when rem(j, 3) == 0 -> i
              err -> err + 1
            end

          err ->
            err + 1
        end
      end)
    end,
    closure: fn ->
      Enum.reduce(inputs, 0, fn n, _acc ->
        fun = fn err -> err + 1 end

        case n do
          i when rem(i, 2) == 0 ->
            case i do
              j when rem(j, 3) == 0 -> i
              err -> fun.(err)
            end

          err ->
            fun.(err)
        end
      end)
    end,
    wrapped_tuple: fn ->
      Enum.reduce(inputs, 0, fn n, _acc ->
        case n do
          i when rem(i, 2) == 0 ->
            case i do
              j when rem(j, 3) == 0 -> {:ok, i}
              err -> {:error, err}
            end

          err ->
            {:error, err}
        end
      end)
      |> case do
        {:ok, success} -> success
        {:error, err} -> err + 1
      end
    end,
    ref: fn ->
      Enum.reduce(inputs, 0, fn n, _acc ->
        ref = make_ref()

        case n do
          i when rem(i, 2) == 0 ->
            case i do
              j when rem(j, 3) == 0 -> i
              err -> {ref, err}
            end

          err ->
            {ref, err}
        end
        |> case do
          {^ref, err} -> err + 1
          success -> success
        end
      end)
    end
  ],
  memory_time: 0.5
)
