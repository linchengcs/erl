%% ---
%%  Excerpted from "Programming Erlang",
%%  published by The Pragmatic Bookshelf.
%%  Copyrights apply to this code. It may not be used to create training material,
%%  courses, books, articles, and the like. Contact us if you are in doubt.
%%  We make no guarantees that this code is fit for any purpose.
%%  Visit http://www.pragmaticprogrammer.com/titles/jaerlang for more book information.
%%---
-module(stream).

-export([start/0, stop/0]).
-export([query_image/0]).
-export([test2/1]).

start() ->
    spawn(fun() ->
                  register(image, self()),
                  process_flag(trap_exit, true),
                  Port = open_port({spawn, "./video_provider"}, [{packet, 2}]),
                  loop(Port)
          end).

stop() ->
    image ! stop.

%% stream_image(From) ->
%%     Data =  query_image(),
%%     From ! Data.

%% stream_images(From) ->
%%     stream_image(From),
%%     {ok, _} = timer:apply_after(100, ?MODULE, stream_images, []).

query_image() -> call_port({get}).

%% query_images() ->
%%     Data = query_image(),
%%     io:format("~n~p~n", [Data]),
%%     {ok, _} = timer:apply_after(100, ?MODULE, query_images, []).

call_port(Msg) ->
    image ! {call, self(), Msg},
    receive
        {image, Result} ->
            Result
    end.

loop(Port) ->
    receive
        {start, From} ->
            repeat_test(Port, From),
%%            repeat_send(From, <<"hel">>),
            loop(Port);
        {call, Caller, Msg} ->
            Port ! {self(), {command, encode(Msg)}},
            receive
                {Port, {data, Data}} ->
                    Caller ! {image, Data}
            end,
            loop(Port);
        stop ->
            Port ! {self(), close},
            receive
                {Port, closed} ->
                    exit(normal)
            end;
        {'EXIT', Port, Reason} ->
            exit({port_terminated,Reason})
    end.

encode({get}) -> [1].

%% test1(Node) ->
%%     Data = rpc:call(Node, stream, query_image, []),
%%     io:format("~n~p~n", [Data]),
%%     {ok, _} = timer:apply_after(1000, ?MODULE, test1, [Node]).
    %% timer:sleep(1000),
    %% rpcs(Node).

test2(Node) ->
    rpc:call(Node, stream, start, []),
    Pid = rpc:call(Node, erlang, whereis, ['image']),
    Pid ! {start, self()},
%%    timer:sleep(1000),
    repeat_recv().


%% repeat_send(Pid, Msg) ->
%%     Pid ! Msg,
%%     {ok, _} = timer:apply_after(1000, ?MODULE, repeat_send, [Pid, Msg]).
%% %%    repeat_send(Pid, Msg).

repeat_test(Port, From) ->
    Port ! {self(), {command, [1]}},
    receive
        {Port, {data, Data}} ->
            From ! {data, Data}
    end,
    timer:sleep(2000),
    repeat_test(Port, From).
%%   {ok, _} = timer:apply_after(1000, ?MODULE, repeat_test, [Port, From]).

%% test(Port) ->
%%     Port ! {self(), {command, [1]}},
%%     receive
%%         {Port, {data, Data}} ->
%%             Data
%%     end.


repeat_recv() ->
    receive
        {data, Data} ->
            io:format("~n~p~n", [Data]);
        _ ->
            io:format("~n~p~n", [os:timestamp()])
    end,
    repeat_recv().
