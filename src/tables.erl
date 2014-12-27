-module(tables).

-export([init/0,post/3,read/0]).

-record(post,
        {date,title, content}).

init() ->
    mnesia:create_table(post,
                        [
                         {attributes,record_info(fields, post)},
                         {disc_copies,[node()]}
                        ]).

post(Title, Content, Date) ->
    Row = #post{
             title = Title,
             content = Content,
             date = Date
            },
    %% mnesia:dirty_write(Row).

    F = fun() ->
                mnesia:write(Row)
        end,
    mnesia:transaction(F).

read() ->
    mnesia:dirty_read(post, <<"test">>).
    %% do(qlc:q([X || X <- mnesia:table(post)])).

%% do(Q) ->
%%     F = fun() -> qlc:e(Q) end,
%%     {atomic, Val} = mnesia:transaction(F),
%%     Val.
