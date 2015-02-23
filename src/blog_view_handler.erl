-module(blog_view_handler).

-export([view/1, view/0, init/3]).

-export([do/1, record_to_proplist/1]).

-include_lib("stdlib/include/qlc.hrl").

-record(post,{date,title,content}).

view(ID) ->
    mnesia:dirty_read(post, ID).

view() ->
    mnesia:dirty_read(post,<<"">>).

init(_, Req, _Ops) ->

    %% Table = mnesia:table(post),
    %% Query = qlc:q([P || P <- Table]),
    %% Query1 = qlc:sort(Query, [{order, descending}]),
    %% Rs = do(Query1),
    %% _PL = [{struct,record_to_proplist(X)} || X <- Rs],
    %% _Json = mochijson2:encode({array,_PL}),
    %% io:format("~p",[_Json]),
    {Token, Req1}  = cowboy_req:qs_val(<<"token">>, Req),
    case authenticate:token(Token) of
        true ->
            PL = emongo:find(post,"post",[{"date",[{'>=',0}]}],[{orderby,[{"date",desc}]}]),
            _PL = [ {struct,  _Y} || [_ | _Y] <- PL],
            _Json = mochijson2:encode({array, _PL}),

            %% io:format("~p~n",[PL]),
            %% io:format("~p~n",[_PL]),

            _Out = _Json,
            Req2 = cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],_Out, Req1),
            {ok, Req2, _Ops};
        _ ->
            cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],<<"">>, Req1),
            {error, Req1, _Ops}
    end.

%%% private function %%%
do(Q) ->
    F = fun() ->  qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

%% rec2proplist(Rec, Obj) ->
%%      lists:zip(record_info(fields, Rec), tl(tuple_to_list(Obj)));


record_to_proplist(#post{} = Rec) ->
    lists:zip(record_info(fields, post), tl(tuple_to_list(Rec))).
