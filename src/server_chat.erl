-module('server_chat').
-export([start/0]).

start() ->
    {ok, Listen} = gen_tcp:listen(2345,[binary, {packet,0},{reuseaddr,true},{active,true}]),
    case whereis(irc) of
        undefined -> irc:start();
        _ -> true
    end,
    spawn(fun()->one(Listen) end).

one(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() -> one(Listen) end),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp,Socket,Bin} ->
            irc ! {broadcast, self(), [Bin]},
            io:format("Message received ~p~n", [Bin]),
            gen_tcp:send(Socket,"You said: "),
            %% Str = binary_to_term(Bin),
            %% Reply = lib_misc:string2value(Str),
            gen_tcp:send(Socket,Bin),
%%            io:format("msg sent: ~p~n", [Reply]),
            loop(Socket);
        {irc, B} ->
            gen_tcp:send(Socket, B),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("Socket closed ~n")
    end.
