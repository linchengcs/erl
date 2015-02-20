-module(authenticate).

-export([authenticate/2, valid/1]).

authenticate(<<"rick">>, <<"chenglin">>) ->
    true;

authenticate(_Username, _Password) ->
    false.

valid(Req) ->
    case cowboy_req:cookie(<<"username">>, Req) of
        {Username, _} ->
            case Username of
                <<"chenglin">> ->
                    true;
                _ ->
                    false
            end;
        _ ->
            false
    end.
