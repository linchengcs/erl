	PROJECT = blog
	DEPS = erlydtl cowboy emongo
	dep_emongo = git https://github.com/jkvor/emongo
	include erlang.mk
