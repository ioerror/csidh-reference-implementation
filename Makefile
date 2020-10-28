
BITS?=512

ifndef UINT_IMPL
	UINT_IMPL=uint.c
	ifneq ("$(wildcard p${BITS}/uint.s)", "")
		UINT_IMPL="$(wildcard p${BITS}/uint.*)"
	endif
endif

ifndef FP_IMPL
	FP_IMPL=fp.c
	ifneq ("$(wildcard p${BITS}/fp.s)", "")
		FP_IMPL="$(wildcard p${BITS}/fp.*)"
	endif
endif



all:
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		p${BITS}/constants.c \
		rng.c \
		${UINT_IMPL} ${FP_IMPL} \
		mont.c \
		csidh.c \
		main.c \
		-o main

debug:
	cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-g \
		p${BITS}/constants.c \
		rng.c \
		${UINT_IMPL} ${FP_IMPL} \
		mont.c \
		csidh.c \
		main.c \
		-o main


bench:
	@cc \
		$(if ${BENCH_ITS},-DBENCH_ITS=${BENCH_ITS}) \
		$(if ${BENCH_VAL},-DBENCH_VAL=${BENCH_VAL}) \
		$(if ${BENCH_ACT},-DBENCH_ACT=${BENCH_ACT}) \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		p${BITS}/constants.c \
		rng.c \
		${UINT_IMPL} ${FP_IMPL} \
		mont.c \
		csidh.c \
		bench.c \
		-o bench


clean:
	@rm -f main bench

