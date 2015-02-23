
-module(blog_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).


start(_Type, _Args) ->
    %% application:start(observer),
    %% application:start(mnesia),
    %% mnesia:start(),
    Dispatch = cowboy_router:compile([{'_',[
					    {"/",index_handler,[]},
					    {"/get",get_handler,[]},
					    {"/login",login_handler,[]},
					    {"/post_rest",post_rest_handler,[]},
					    {"/post",blog_view_handler,[]},
					    {"/blog",blog_handler,[]},
                                            {"/cookie",cookie_handler,[]},
                                            {"/websocket/clock1",clock1_handler,[]},
                                            {"/websocket",ws_handler,[]},
                                            {"/compress",compress_handler,[]},
                                            {"/chucked",chuncked_handler,[]},
                                            {"/auth",auth_handler,[]},
                                            {"/stream",stream_handler,[]},
                                            {"/eventsource",eventsource_handler,[]},
                                            {"/upload",upload_handler,[]},
					    {"/create",create_handler,[]},
					    {"/save",save_handler,[]},
                                            {"/input_video", input_video_handler,[]},
                                            {"/video_ws", video_ws_handler,[]},
                                            {"/[...]", cowboy_static, {priv_dir, blog, "",[{mimetypes, cow_mimetypes, all}]}},
					    {"/hello", hello_handler,[]}
					   ]}]),
      cowboy:start_http(my_http_listener, 100, [{port, 8888}], [{env, [{dispatch, Dispatch}]}]),
	%% {ok, _} = cowboy:start_http(my_http_listener, 100, [{port, 8888}], [
	%% 	{env, [{dispatch, Dispatch}]},
	%% 	{middlewares, [cowboy_router, markdown_converter, cowboy_handler]}
	%% ]),
%    spawn(tcp_server, start, []),
    emongo:add_pool(post,"localhost", 27017, "db_post", 1),
    server_chat:start(),
    video_broadcast:start(),
    blog_sup:start_link().

stop(_State) ->
    ok.
