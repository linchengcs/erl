%% Feel free to use, reuse and abuse the code in this file.

%% @doc Cookie handler.
-module(login_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, PostVals, Req2} = cowboy_req:body_qs(Req),
    io:format("~p",[PostVals]),
    Username = proplists:get_value(<<"username">>, PostVals),
    Password = proplists:get_value(<<"password">>, PostVals),
    Bool = authenticate:authenticate(Username, Password),
    Json = case Bool of
               true ->
                   <<"{\"ret\":0,\"username\":\"rick\",\"token\":\"cptbtptpbcptdtptp\"}">>;
               false ->
                   <<"{\"ret\":1,\"username\":\"rick\"}">>
           end,
    {ok, Req4} = cowboy_req:reply(200,
                                  [{<<"content-type">>, <<"text/html">>}],
                                  Json, Req2),
    {ok, Req4, State}.

terminate(_Reason, _Req, _State) ->
    ok.


%% authenticate(<<"rick">>, <<"chenglin">>) ->
%%     true;

%% authenticate(_Username, _Password) ->
%%     false.
