-module(video_broadcast).
-export([start/0]).

start() ->
    register(video_broadcast, spawn(fun()->loop([]) end)).

loop(L) ->
    receive
        {broadcast, _Pid, Data} ->
            broadcast(L, Data),
            loop(L);
        {connect, Pid} ->
            L1 = L ++ [Pid],
            loop(L1)
    end.

broadcast(L, Data) ->
%    io:format("~p", [Data]),
    [Pid ! {frame,Data} || Pid <- L].
