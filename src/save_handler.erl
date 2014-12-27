%% Feel free to use, reuse and abuse the code in this file.

%% @doc POST echo handler.
-module(save_handler).

-export([init/3]).

%%-compile([{parse_transform, lager_transform}]).


init(_, Req, _Ops) ->
    io:format("this is output msg: ~p-n", [Req]),
    %% ct:log("this if log"),
    %% lib_misc:dump('dump',Req),
    log:dump(Req),
    log:dump("this is fom save"),
    log:sdump("this is from log sdump"),
    %% lager:start(),
    %% lager:error("this ia a lager error"),
    %% lager:info("this is a info "),
    %% lager:warning("this is a warn from lager"),

    {ok, Body} = index_dtl:render([{name, <<"Rick">>}]),
    Method = cowboy_req:method(Req),
    io:format("~nblablabla======================>~p~n", [Method]),
    Map = cowboy_req:match_qs([echo], Req),
    io:format("~n query string======================>~p~n", [Map]),
    io:format("~nblablabla======================>~p~n", [Method]),
    Req = cowboy_req:reply(200,[{<<"content-type">>,<<"text/html">>}], Body, Req),
    {ok, Req, _Ops}.
