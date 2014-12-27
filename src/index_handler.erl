%% welcome page
-module(index_handler).

-export([init/3]).

%% -compile([{parse_transform, lager_transform}]).

init(_, Req, _Ops) ->
    %% lager:start(),
    %% lager:info("this is a log from index by lager"),
    V = tables:read(),
    io:format("~p", [V]),
    io:format("this is output msg: ~p-n", [Req]),
    {ok, Body} = index_dtl:render([{name, <<"Rick">>}]),
    Req = cowboy_req:reply(200,[{<<"content-type">>,<<"text/html">>}], Body, Req),
    {ok, Req, _Ops}.
