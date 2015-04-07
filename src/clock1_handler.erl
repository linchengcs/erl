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

    Node = 'wrt@101.244.119.158',
%%    rpc:call(Node, stream, stop, []),
      Pid = rpc:call(Node, stream, start, []),
%%    Pid = rpc:call(Node, erlang, whereis, ['image']),
io:format("~p~n",[Pid]),
    Pid ! {start, self()},
%%	Pid ! stop,
    {ok, Req1, Pid, hibernate}.

websocket_handle({text, Msg}, Req, Pid) ->
%%    Pid ! Msg,
    handle_command(Msg, Pid),
    {ok, Req, Pid}.
%%        {reply, {text, << "That's handle! ", Msg/binary >>}, Req, Pid}.

websocket_info(Info, Req, Pid) ->
%%    io:format("Handle_info Info:~p Pid:~p~n",[Info,Pid]),
%%    error_logger:error_msg("An error has occurred, dont worry, just test\n"),
 %%   {ok, Req, Pid, hibernate}.
%%    _Info1 = local_pic(),
    {data, Info1} = Info,
%%io:format("~p~n",[os:timestamp()]),
    Info2 = base64:encode(Info1),
%%io:format("~p~n",[os:timestamp()]),
    {reply, {text, Info2}, Req, Pid}.

websocket_terminate(_Reason, _Req, _Pid) ->
    io:format("websocket.erl terminate:~p~p~n", [_Reason, _Pid]),
%%    Node = 'wrt@101.244.119.158',
%%    rpc:call(Node, stream, stop, []),
	_Pid ! stop,
    ok.

%% local_pic() ->
%%     {ok, Pic} = file:read_file('lib/blog-0.1.0/priv/1.jpg'),
%%     base64:encode(Pic).

encode_command(Msg) ->
    case Msg of
        <<"led">> ->
            {command, <<"led">>};
        <<"forward">> ->
            {command, <<"forward">>};
        <<"backward">> ->
            {command, <<"backward">>};
        <<"left">> ->
            {command, <<"left">>};
        <<"right">> ->
            {command, <<"right">>};
        _ ->
            undefined
    end.

handle_command(Msg, Pid) ->
    Encoded = encode_command(Msg),
    io:format("~n~p~n", [Msg]),
    case Encoded of
        {command, _ } ->
            Pid ! Encoded;
        _ ->
           void	 
    end.
