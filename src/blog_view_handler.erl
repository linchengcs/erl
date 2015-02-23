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
    {Token, Req3}  = cowboy_req:qs_val(<<"token">>, Req),
    {Page, Req4} = cowboy_req:qs_val(<<"page">>, Req3),
    {Size, Req5} = cowboy_req:qs_val(<<"size">>, Req4),

    Page1 = binary_to_integer(Page),
    Size1 = binary_to_integer(Size),
    Req1 = Req5,
    case authenticate:token(Token) of
        true ->
            case Page1 of
                -1 ->
                    _PL = emongo:count(post,"post"),
                    _Out = <<"{\"post_count\":", (list_to_binary(integer_to_list(_PL)))/binary, "}">>,
                    io:format("fadf~p",[_Out]),
                    Req2 = cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],_Out, Req1),
                    {ok, Req2, _Ops};
                _ ->
                    PL = emongo:find(post,"post",[{"date",[{'>=',0}]}],[{offset, Page1*Size1}, {limit, Size1}, {orderby,[{"date",desc}]}]),
                    _PL = [ {struct,  _Y} || [_ | _Y] <- PL],
                    _Out = mochijson2:encode({array, _PL}),
                    Req2 = cowboy_req:reply(200, [{<<"content-type">>,<<"text/html">>}],_Out, Req1),
                    {ok, Req2, _Ops}
            end;
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
