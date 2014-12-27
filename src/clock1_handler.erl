-module(clock1_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
        {upgrade, protocol, cowboy_websocket}.

websocket_init(_Transport, Req, _Env) ->
    Req1 = cowboy_req:compact(Req),
    Self = self(),
    %% Spawn an erlang handler
    Pid = spawn_link(clock1, start, [Self]),
%%    Pid = spawn_link(fun()->io:format("hello test") end),
    {ok, Req1, Pid, hibernate}.

websocket_handle({text, Msg}, Req, Pid) ->
    Pid ! Msg,
    {ok, Req, Pid}.
%%        {reply, {text, << "That's handle! ", Msg/binary >>}, Req, Pid}.

websocket_info(Info, Req, Pid) ->
    io:format("Handle_info Info:~p Pid:~p~n",[Info,Pid]),
    error_logger:error_msg("An error has occurred, dont worry, just test\n"),
 %%   {ok, Req, Pid, hibernate}.
        {reply, {text, Info}, Req, Pid}.

websocket_terminate(_Reason, _Req, Pid) ->
    io:format("websocket.erl terminate:~n"),
    exit(Pid, socketClosed),
    ok.
