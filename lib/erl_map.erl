-module(erl_map).
-export([comprehension/1, anonymous/1, comprehension_case/1, anonymous_case/1]).

comprehension(List) -> [X + 1 || X <- List].

anonymous(List) ->
  (fun Rec([]) ->
      [];
    Rec([H | T]) ->
      [H + 1 | Rec(T)]
  end)(List).

comprehension_case(Enum) ->
  F = fun (X) -> X + 1 end,
  case Enum of
    List when is_list(List) -> [F(X) || X <- List];
    _ -> 'Elixir.Enum':map(Enum, F)
  end.

anonymous_case(Enum) ->
  F = fun (X) -> X + 1 end,
  case Enum of
    List when is_list(List) ->
      (fun Rec([]) ->
          [];
        Rec([H | T]) ->
          [F(H) | Rec(T)]
      end)(List);
    _ -> 'Elixir.Enum':map(Enum, F)
  end.