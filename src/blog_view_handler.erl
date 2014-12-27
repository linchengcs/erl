-module(blog_view_handler).

-export([view/1, view/0, init/3]).

-record(post,{title,content,date}).

view(ID) ->
    mnesia:dirty_read(post, ID).

view() ->
    mnesia:dirty_read(post,<<"">>).

init(_, Req, _Ops) ->
    [Val | _] = view(<<"test">>),
    io:format("~p", [Val]),
    #post{title=_Title, content=_Content, date=_Date} = Val,
    io:format("~p",[_Title]),
    Req = cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],_Content, Req),
    {ok, Req, _Ops}.
