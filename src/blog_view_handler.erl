-module(blog_view_handler).

-export([view/1, view/0, init/3]).

-include_lib("stdlib/include/qlc.hrl").

-record(post,{date,title,content}).

view(ID) ->
    mnesia:dirty_read(post, ID).

view() ->
    mnesia:dirty_read(post,<<"">>).

init(_, Req, _Ops) ->
%%     [Val | _] = view(<<"test">>),
%% %%    io:format("~p", [Val]),
%%     #post{title=_Title, content=_Content, date=_Date} = Val,
%% %%    io:format("~p",[_Title]),

    Table = mnesia:table(post),
    Query = qlc:q([P || P <- Table]),
    Query1 = qlc:sort(Query, [{order, descending}]),
    Rs = do(Query1),
    %% [_Val1 | _] = Rs,
    %% _PL = record_to_proplist(_Val1),
    %% _Json = mochijson2:encode({struct,_PL}),
    %% io:format("~n~n~n~p~n~n~n~n",[Rs]),
    %% io:format("~p~p", [_PL,_Json]),

    _PL = [{struct,record_to_proplist(X)} || X <- Rs],
    _Json = mochijson2:encode({array,_PL}),
    io:format("~p",[_Json]),




    _Out = _Json,
    Req = cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],_Out, Req),
    {ok, Req, _Ops}.


%%% private function %%%
do(Q) ->
    F = fun() ->  qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

%% rec2proplist(Rec, Obj) ->
%%      lists:zip(record_info(fields, Rec), tl(tuple_to_list(Obj)));


record_to_proplist(#post{} = Rec) ->
    lists:zip(record_info(fields, post), tl(tuple_to_list(Rec))).
