%% Feel free to use, reuse and abuse the code in this file.

%% @doc POST echo handler.
-module(blog_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req2),
    {ok, PostVals, Req3} = cowboy_req:body_qs(Req2),
    Title = proplists:get_value(<<"title">>, PostVals),
    Content = proplists:get_value(<<"content">>, PostVals),
    io:format("~p~p~p~p~p",[Method,HasBody,PostVals,Title,Content]),
    Current = calendar:local_time(),
    Ts = calendar:datetime_to_gregorian_seconds(Current),
    tables:post(Title,Content,Ts),
%%    mnesia:dirty_write(#post{title=Title,content=Content,date=<<"date">>}),
    %% cowboy_req:reply(200, [
    %%                        {<<"content-type">>, <<"text/plain; charset=utf-8">>}
    %%                       ], <<"hhh">>, Req3),

    %% {ok, Headers, Req2} = cowboy_req:part(Req),
    %% {ok, Data, Req3} = cowboy_req:part_body(Req2),
    %% {file, <<"file">>, Filename, ContentType, _TE}
    %%     = cow_multipart:form_data(Headers),
    %% file:write_file("upload", Data),
    %% io:format("Received file ~p of content-type ~p as follow:~n~p~n~n",
    %%           [Filename, ContentType, Data]),

    cowboy_req:reply(200, [
                           {<<"content-type">>, <<"text/plain; charset=utf-8">>}
                          ], <<"hello">>, Req3),

    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
