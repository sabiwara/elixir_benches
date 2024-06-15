{module, 'Elixir.Bench'}.  %% version = 0

{exports, [{'__info__',1},
           {foo,1},
           {local,1},
           {local_closure,0},
           {module,1},
           {module_info,0},
           {module_info,1},
           {remote_closure,0}]}.

{attributes, []}.

{labels, 26}.


{function, '__info__', 1, 2}.
  {label,1}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench'},{atom,'__info__'},1}.
  {label,2}.
    {select_val,{x,0},
                {f,9},
                {list,[{atom,attributes},
                       {f,8},
                       {atom,compile},
                       {f,8},
                       {atom,deprecated},
                       {f,7},
                       {atom,exports_md5},
                       {f,6},
                       {atom,functions},
                       {f,5},
                       {atom,macros},
                       {f,7},
                       {atom,md5},
                       {f,8},
                       {atom,module},
                       {f,4},
                       {atom,struct},
                       {f,3}]}}.
  {label,3}.
    {move,{atom,nil},{x,0}}.
    return.
  {label,4}.
    {move,{atom,'Elixir.Bench'},{x,0}}.
    return.
  {label,5}.
    {move,{literal,[{foo,1},
                    {local,1},
                    {local_closure,0},
                    {module,1},
                    {remote_closure,0}]},
          {x,0}}.
    return.
  {label,6}.
    {move,{literal,<<23,253,119,194,33,204,205,227,211,208,5,195,55,16,104,222>>},
          {x,0}}.
    return.
  {label,7}.
    {move,nil,{x,0}}.
    return.
  {label,8}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
  {label,9}.
    {call_only,1,{f,25}}. % '-inlined-__info__/1-'/1


{function, foo, 1, 11}.
  {label,10}.
    {line,[{location,"bench/local_vs_module.exs",16}]}.
    {func_info,{atom,'Elixir.Bench'},{atom,foo},1}.
  {label,11}.
    {gc_bif,'+',{f,0},1,[{x,0},{integer,1}],{x,0}}.
    return.


{function, local, 1, 13}.
  {label,12}.
    {line,[{location,"bench/local_vs_module.exs",9}]}.
    {func_info,{atom,'Elixir.Bench'},{atom,local},1}.
  {label,13}.
    {test_heap,{alloc,[{words,0},{floats,0},{funs,1}]},1}.
    {make_fun3,{f,11},0,0,{x,1},{list,[]}}.
    {'%',{var_info,{x,1},[{fun_type,{t_number,any}}]}}.
    {line,[{location,"bench/local_vs_module.exs",10}]}.
    {call_ext_only,2,{extfunc,'Elixir.Enum',each,2}}.


{function, local_closure, 0, 15}.
  {label,14}.
    {line,[{location,"bench/local_vs_module.exs",13}]}.
    {func_info,{atom,'Elixir.Bench'},{atom,local_closure},0}.
  {label,15}.
    {test_heap,{alloc,[{words,0},{floats,0},{funs,1}]},0}.
    {make_fun3,{f,11},0,0,{x,0},{list,[]}}.
    {'%',{var_info,{x,0},[{fun_type,{t_number,any}}]}}.
    return.


{function, module, 1, 17}.
  {label,16}.
    {line,[{location,"bench/local_vs_module.exs",5}]}.
    {func_info,{atom,'Elixir.Bench'},{atom,module},1}.
  {label,17}.
    {move,{literal,fun 'Elixir.Bench':foo/1},{x,1}}.
    {line,[{location,"bench/local_vs_module.exs",6}]}.
    {call_ext_only,2,{extfunc,'Elixir.Enum',each,2}}.


{function, remote_closure, 0, 19}.
  {label,18}.
    {line,[{location,"bench/local_vs_module.exs",14}]}.
    {func_info,{atom,'Elixir.Bench'},{atom,remote_closure},0}.
  {label,19}.
    {move,{literal,fun 'Elixir.Bench':foo/1},{x,0}}.
    return.


{function, module_info, 0, 21}.
  {label,20}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench'},{atom,module_info},0}.
  {label,21}.
    {move,{atom,'Elixir.Bench'},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 23}.
  {label,22}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench'},{atom,module_info},1}.
  {label,23}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.


{function, '-inlined-__info__/1-', 1, 25}.
  {label,24}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench'},{atom,'-inlined-__info__/1-'},1}.
  {label,25}.
    {jump,{f,24}}.
