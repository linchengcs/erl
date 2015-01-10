-module(irc).
-export([start/0]).

start() ->
    register(irc, spawn(fun() -> start1() end)).

start1() ->
    process_flag(trap_exit, true),
    loop([]).

loop(L) ->
    receive
	{broadcast, Pid, Txt} ->
	    case lists:member(Pid,L) of
		false ->
		    L1 = L ++ [Pid],
                    broadcast(L1, Txt),
                    loop(L1);
		_ ->
                    broadcast(L, Txt),
                    loop(L)
	    end;
        X ->
            io:format("irc:received:~p~n",[X]),
            loop(L)
    end.

broadcast(L,  B) ->
    io:format("Pid list: ~p~n", [L]),
    [Pid !  {irc, B} || Pid <- L].

