To build with default parameters, simply run `make` and then `sudo make
install` to install the corresponding tools to the system. The default
parameter BITS is set to 512.

To build a shared library and the corresponding `csidh-p*-util` program, simply
run:

  `make shared-library`

To install:

  `sudo make install`

Generate one CSIDH private and public key per user:
```
$ csidh-p512-util -g -s demo-512-0.secret  -p demo-512-0.public
$ csidh-p512-util -g -s demo-512-1.secret  -p demo-512-1.public
```

Perform a key agreement from the perspective of each respective user:
```
$ csidh-p512-util -d -s demo-512-0.secret  -p demo-512-1.public
c7cee77cb809e99a3d38c661f53fe1a1be0f0b6071f490e6a260f7c0b28774c548e09158d5193f118a418a800683ec51be6814d156fdb34b2b3310d3ae8f8b4a
$ csidh-p512-util -d -s demo-512-1.secret  -p demo-512-0.public
c7cee77cb809e99a3d38c661f53fe1a1be0f0b6071f490e6a260f7c0b28774c548e09158d5193f118a418a800683ec51be6814d156fdb34b2b3310d3ae8f8b4a
```

It is also possible to use stdin and stdout:
```
$ cat demo-512-0.secret | csidh-p512-util -d -p demo-512-1.public
c7cee77cb809e99a3d38c661f53fe1a1be0f0b6071f490e6a260f7c0b28774c548e09158d5193f118a418a800683ec51be6814d156fdb34b2b3310d3ae8f8b4a
$ cat demo-512-0.secret demo-512-1.public | csidh-p512-util -d
c7cee77cb809e99a3d38c661f53fe1a1be0f0b6071f490e6a260f7c0b28774c548e09158d5193f118a418a800683ec51be6814d156fdb34b2b3310d3ae8f8b4a
```

To build a static library and a statically linked `csidh-p*-util` program,
simply run:

  `make static-library`

The build may be configured with other arguments:

- BITS is one of the supported parameter sets.
- UINT_IMPL is an unsigned integer implementation.
- FP_IMPL is a finite field implementation.

For example:

  `make BITS=1024`

builds the code with a 1024-bit parameter set, and

  `make UINT_IMPL=ui.c FP_IMPL=fp.c`

uses generic C arithmetic instead of assembly.


Other parameter sets may be used by creating a
directory modelled after the p512/ and p1024/
folders, optionally including specialized ui.s
and fp.s files for assembly arithmetic.  Else
the generic C implementation will be used.


To build the benchmark code, run "make bench"; it
also supports the arguments listed above.
To configure benchmarking, use the following options:

- BENCH_ITS is the number of iterations.
- BENCH_VAL benchmarks public-key validation.
- BENCH_ACT benchmarks the group action.

For example,

  `make bench BENCH_ITS=1000 BENCH_ACT=1 BENCH_VAL=0`

builds a benchmark for 1000 iterations of the group
action without public-key validation.

## Benchmarks 
A simple benchmark and CSIDH shared secret agreement demonstration on use with
a `Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz`:

  ```
  $ csidh-p512-bench
  doing 1000 iterations of validation and action.
  iterations: 1000
  clock cycles: 125700756 (125.7*10^6)
  wall-clock time: 48.493 ms
  stack memory usage: 4368 b
  ```

Shared secret derivation with timing information:

  ```
  $ csidh-p512-demo

  Alice's private key   (  0.500 ms):
    0c0c010d4dfeecd0025ecf1f2b11bed02be3422f1feddbec5dbb301e1315f02f4c0124e55f

  Bob's private key     (  0.404 ms):
    ecd0b4f23b3e33d2e1345c45ee4502def2bf122114ef41b053eee04425cdb05d1d43e2e5c1

  Alice's public key    ( 70.244 ms):
    3a6e03ff0cfe3fcfac6f4b4ea69fa62366a8a20051061814926b535c38fc4a015dc6f0e6bc3dc449e5a4f9117e7696470f96488e9fab164d6ce0c39d5ea6fdac

  Bob's public key      ( 37.351 ms):
    54ae89e13e63dc86065f96a210598dbe81f790e4c519735bea6e703804677931462f7c50e2411a9a515f26a519159a935e4f3db96feef0543396171050fc7322

  Alice's shared secret ( 36.721 ms):
    2dfee422f92e7ee93a2ecd102300d4a4b67c66fd451244fb444f5e9675c6f4dc6e1a55d81818194019b63efc9dcb67b518b344ade7476e2acf870186cd26421b

  Bob's shared secret   ( 42.306 ms):
    2dfee422f92e7ee93a2ecd102300d4a4b67c66fd451244fb444f5e9675c6f4dc6e1a55d81818194019b63efc9dcb67b518b344ade7476e2acf870186cd26421b

      equal.
  ```

The same benchmark and key agreement on a `Raspberry Pi 4 Model B Rev 1.1`:

  ```
  $ csidh-p512-bench
  doing 1000 iterations of validation and action.
  iterations: 1000
  clock cycles: 29717321 (29.7*10^6)
  wall-clock time: 549.508 ms
  stack memory usage: 4768 b
  ```

Shared secret derivation with timing information:

  ```
  $ csidh-p512-demo

Alice's private key   (  0.371 ms):
  d5311d13ddb14c3ebf52bc4020fd5fc34cfc1fef223512df3d25343d55ed445d4fb0c115f2

Bob's private key     (  0.415 ms):
  dd0eed2dfd0401eeb4454b41bf2ce3bccf1423c0232cec02bb3ff2e20bee15bdded511fb2e

Alice's public key    (571.734 ms):
  50721ee9067ece5fbae5d6864017352d0b3fb892daa828cbb618baeb4288475b74a60bd5341c2893025549fb6a0288330d8eb056a69be5a6d0822245558b1b82

Bob's public key      (529.899 ms):
  1b3d030d38f70ee2aa5083d3681aa4a13cd0f6469f7ac37033c4dc9c66c1fa164aff569fafda029bb48d7d2a279895ef151372f3f7c9cc236d9a6f0fd0223570

Alice's shared secret (578.907 ms):
  5a075d7f4f5e37fa95bd6103bc71bdd2e98173078e26dd2aeaf3f9581ff847056e6e781cea986991e43ffeb4e68fc2763a9059088296ded0a0df415ffd4913fa

Bob's shared secret   (534.403 ms):
  5a075d7f4f5e37fa95bd6103bc71bdd2e98173078e26dd2aeaf3f9581ff847056e6e781cea986991e43ffeb4e68fc2763a9059088296ded0a0df415ffd4913fa

    equal.
  ```

The same benchmark and key agreement on a `Raspberry Pi 3 Model B Rev 1.2`:

  ```
  $ csidh-p512-bench
  doing 1000 iterations of validation and action.
  iterations: 1000
  clock cycles: 22086467 (22.1*10^6)
  wall-clock time: 1148.395 ms
  stack memory usage: 4768 b
  ```

Shared secret derivation with timing information:
  ```
  $ csidh-p512-demo

  Alice's private key   (  0.301 ms):
    4d004fb0fe1be55c050c03b03f31d30f0d2b245bd2e21103fe40b4f520345cc5b554e5ecde

  Bob's private key     (  0.240 ms):
    0d3f0ccb504c2debe14c51b21db4c0f22dccf5e2ee5cbbe1ed20f322c414f2d23440d00223

  Alice's public key    (1175.329 ms):
    4f6c8630d59f524651d0caa010605528df9e8588a6560b94bde3ab276745ebb164ec65d9c6f7ac04d8787d7084118ce48d36eba3f4d8afcf25bdee60a5dbcf49

  Bob's public key      (1063.863 ms):
    621279da5aab0140668e4db8d0ad021e92fdb7119a7950a69cd98337bd31366d5385238f75f58fc0a28efc71e5b0a0f798a474c91048843253e05acf33cfdc8e

  Alice's shared secret (1158.707 ms):
    1eb8091dbc7e3949a22f159676506a5de136ca3912624b0a1fb2d24dce5a5b65bb3724d66834c166125f0192aa5260b338ae156e28251d9309a67d297c722684

  Bob's shared secret   (1077.129 ms):
    1eb8091dbc7e3949a22f159676506a5de136ca3912624b0a1fb2d24dce5a5b65bb3724d66834c166125f0192aa5260b338ae156e28251d9309a67d297c722684

      equal.
  ```

