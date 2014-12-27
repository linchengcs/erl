%% welcome page
-module(create_handler).

-export([init/3]).

init(_, Req, _Ops) ->
    {ok, Body} = create_dtl:render([{name, <<"Rick">>}]),
    Req = cowboy_req:reply(200,[{<<"content-type">>,<<"text/html">>}], Body, Req),
    {ok, Req, _Ops}.
