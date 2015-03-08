-module(post_rest_handler).

-export([init/3, allowed_methods/2, content_types_accepted/2, rest_terminate/2]).

-export([put_post/2, delete_resource/2]).

init(_Transport, _Req, []) ->
    {Token, _Req1}  = cowboy_req:qs_val(<<"token">>, _Req),
    case authenticate:token(Token) of
        true ->
            {upgrade, protocol, cowboy_rest};
        _ ->
            {halt, _Req1, ok}
    end.

allowed_methods(Req, State) ->
    {[<<"PUT">>,<<"DELETE">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{{<<"application">>,<<"x-www-form-urlencoded">>,[]},put_post}], Req, State}.

rest_terminate(_Req, _State) ->
    ok.

put_post(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req2),
    {ok, PostVals, Req3} = cowboy_req:body_qs(Req2),
    Title = proplists:get_value(<<"title">>, PostVals),
    Content = proplists:get_value(<<"content">>, PostVals),
    Tag = proplists:get_value(<<"tag">>, PostVals),
    Date = proplists:get_value(<<"date">>, PostVals),
    Date1 = case Date of
                <<"0">> ->
                    Current = calendar:local_time(),
                    calendar:datetime_to_gregorian_seconds(Current);
                _Other -> list_to_integer(binary_to_list(Date))
            end,
    io:format("~p~p~p~p~p~p",[Method,HasBody,PostVals,Title,Content, Date1]),
    emongo:update(post, "post", [{"date", Date1}], [{"title",Title}, {"content", Content}, {"date", Date1}, {"tag", Tag}], true),
%    emongo:insert(post, "post", [{"title",Title}, {"content", Content}, {"date", Date1}]),

    Req1 = Req3,
    %Req1 = cowboy_req:set_resp_body(<<"hello,put">>,Req),
    {ok, Req1} = cowboy_req:reply(200,
                                  [{<<"content-type">>, <<"text/html">>}],
                                  <<"hello put">>, Req),
    {true, Req1, State}.

delete_resource(Req, State) ->
    %% {Method, Req2} = cowboy_req:method(Req),
    %% HasBody = cowboy_req:has_body(Req2),
    {ok, PostVals, Req1} = cowboy_req:body_qs(Req),
    Date = proplists:get_value(<<"date">>, PostVals),
    io:format("========================~p=================~n~n~n",[Date]),
    emongo:delete(post, "post", [{"date",list_to_integer(binary_to_list(Date))}]),
    {ok, Req1} = cowboy_req:reply(200,
                                  [{<<"content-type">>, <<"text/html">>}],
                                  <<"hello delete">>, Req),
    {true, Req1, State}.
