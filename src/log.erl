-module(log).

-export([dump/1, sdump/1]).

dump(Term) ->
    {ok, S} = file:open("log/dump.txt", [append]),
    io:format(S, "~p.~n", [Term]),
    file:close(S).

sdump(Term) ->
    Pid = spawn(fun()->dump(Term) end),
    Pid.
