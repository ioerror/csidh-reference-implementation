BITS?=512
ARCH := $(shell uname -p)
CC?=gcc

ifeq (${ARCH}, aarch64)
	A64?=1
UINT_IMPL?=ui.c
FP_IMPL?=fp.c
endif

ifeq (${ARCH}, x86_64)
	X64?=1
endif

ifndef UINT_IMPL
	UINT_IMPL=ui.c
	ifneq ("$(wildcard p${BITS}/ui.s)", "")
		UINT_IMPL="$(wildcard p${BITS}/ui.*)"
	endif
endif

ifndef FP_IMPL
	FP_IMPL=fp.c
	ifneq ("$(wildcard p${BITS}/fp.s)", "")
		FP_IMPL="$(wildcard p${BITS}/fp.*)"
	endif
endif

all: static-library bench
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
		-o csidh-p${BITS}-demo

static-library:
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-c \
		p${BITS}/constants.c \
		rng.c \
		${UINT_IMPL} ${FP_IMPL} \
		mont.c \
		csidh.c
	@ar -cr libcsidh-p${BITS}.a *.o
	@ranlib libcsidh-p${BITS}.a
	@cc csidh_util.c -L./ -lcsidh-p${BITS} \
		$(if ${BENCH_ITS},-DBENCH_ITS=${BENCH_ITS}) \
		$(if ${BENCH_VAL},-DBENCH_VAL=${BENCH_VAL}) \
		$(if ${BENCH_ACT},-DBENCH_ACT=${BENCH_ACT}) \
		$(if ${BITS},-DBITS=${BITS}) \
		$(if ${A64},-DA64) \
		$(if ${X64},-DX64) \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
    -o csidh-p${BITS}-util

shared-library:
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		p${BITS}/constants.c \
		-o p${BITS}-constants.o
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		rng.c \
		-o p${BITS}-rng.o
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		mont.c \
		-o p${BITS}-mont.o
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		csidh.c \
		-o  p${BITS}-csidh.o
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		${FP_IMPL} \
		-o p${BITS}-fp.o
	@cc \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		-c \
		${UINT_IMPL} \
		-o p${BITS}-ui.o
	@cc \
		-fPIC \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-Wl,-Bsymbolic \
		-shared \
		p${BITS}-constants.o \
		p${BITS}-csidh.o \
		p${BITS}-mont.o \
		p${BITS}-rng.o \
		p${BITS}-ui.o \
		p${BITS}-fp.o \
		-fvisibility=hidden \
		-o libcsidh-p${BITS}.so
	@cc csidh-util.c -L./ -lcsidh-p${BITS} \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-DBITS=${BITS} \
    -o csidh-p${BITS}-util

install:
	-install --mode=755 libcsidh-p${BITS}.a ${DESTDIR}/usr/lib/
	-install --mode=755 libcsidh-p${BITS}.so ${DESTDIR}/usr/lib/
	-install --mode=755 csidh-p${BITS}-util ${DESTDIR}/usr/bin/
	-install --mode=755 csidh-p${BITS}-demo ${DESTDIR}/usr/bin/
	-install --mode=755 csidh-p${BITS}-bench ${DESTDIR}/usr/bin/
	-install --mode=755 csidh-p${BITS}.h ${DESTDIR}/usr/include/

uninstall:
	-rm -i ${DESTDIR}/usr/lib/libcsidh-p${BITS}.a
	-rm -i ${DESTDIR}/usr/lib/libcsidh-p${BITS}.so
	-rm -i ${DESTDIR}/usr/bin/csidh-p${BITS}-*

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
		-o csidh-p${BITS}-demo

bench:
	@cc \
		$(if ${BENCH_ITS},-DBENCH_ITS=${BENCH_ITS}) \
		$(if ${BENCH_VAL},-DBENCH_VAL=${BENCH_VAL}) \
		$(if ${BENCH_ACT},-DBENCH_ACT=${BENCH_ACT}) \
		$(if ${A64},-DA64) \
		$(if ${X64},-DX64) \
		-I ./ \
		-I p${BITS}/ \
		-std=c99 -pedantic \
		-Wall -Wextra \
		-march=native -O3 \
		-fPIC \
		p${BITS}/constants.c \
		rng.c \
		${UINT_IMPL} ${FP_IMPL} \
		mont.c \
		csidh.c \
		bench.c \
		-o csidh-p${BITS}-bench

regenerate_test_vectors:
	./csidh-p512-util -g -p sample-keys/1.montgomery.le.pk -s sample-keys/1.montgomery.le.sk
	./csidh-p512-util -g -p sample-keys/2.montgomery.le.pk -s sample-keys/2.montgomery.le.sk
	./csidh-p512-util -g -p sample-keys/3.montgomery.le.pk -s sample-keys/3.montgomery.le.sk
	./csidh-p512-util -g -p sample-keys/4.montgomery.le.pk -s sample-keys/4.montgomery.le.sk
	./csidh-p512-util -d -p sample-keys/2.montgomery.le.pk -s sample-keys/1.montgomery.le.sk > sample-keys/1-2.ss
	./csidh-p512-util -d -p sample-keys/1.montgomery.le.pk -s sample-keys/2.montgomery.le.sk > sample-keys/2-1.ss
	./csidh-p512-util -d -p sample-keys/2.montgomery.le.pk -s sample-keys/3.montgomery.le.sk > sample-keys/3-2.ss
	./csidh-p512-util -d -p sample-keys/3.montgomery.le.pk -s sample-keys/4.montgomery.le.sk > sample-keys/4-3.ss

util_test: static-library
	echo "BEGIN util-test"
	./csidh-p512-util -d -p sample-keys/2.montgomery.le.pk -s sample-keys/1.montgomery.le.sk > sample-keys/1-2.ss.test_result
	diff sample-keys/1-2.ss.test_result sample-keys/1-2.ss
	./csidh-p512-util -d -p sample-keys/1.montgomery.le.pk -s sample-keys/2.montgomery.le.sk > sample-keys/2-1.ss.test_result
	diff sample-keys/2-1.ss.test_result sample-keys/2-1.ss
	./csidh-p512-util -d -p sample-keys/2.montgomery.le.pk -s sample-keys/3.montgomery.le.sk > sample-keys/3-2.ss.test_result
	diff sample-keys/3-2.ss.test_result sample-keys/3-2.ss
	./csidh-p512-util -d -p sample-keys/3.montgomery.le.pk -s sample-keys/4.montgomery.le.sk > sample-keys/4-3.ss.test_result
	diff sample-keys/4-3.ss.test_result sample-keys/4-3.ss
	rm sample-keys/*.test_result
	echo "END util-test"

clean:
	@rm -f main bench *.o *.a *.so csidh-*-util csidh-p*-demo csidh-p*-bench sample-keys/*.test_result
