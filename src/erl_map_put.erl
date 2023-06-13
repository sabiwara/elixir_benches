-module(erl_map_put).
-export([add_keys/1, replace_keys/1]).

add_keys(Map) ->
  Map#{a => 1, b => 2, c => 3, d => 4, e => 5}.

replace_keys(Map) ->
  Map#{a := 1, b := 2, c := 3, d := 4, e := 5}.
