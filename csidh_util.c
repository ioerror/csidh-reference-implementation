#include <getopt.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>

#include "csidh_util.h"

void pprint_pk(public_key *x) {
  for (size_t i = 0; i < sizeof(public_key); ++i) {
    printf("%02hhx", ((uint8_t *)x)[i]);
  }
  printf("\n");
}

void pprint_sk(private_key *y) {
  for (size_t i = 0; i < sizeof(private_key); ++i) {
    printf("%02hhx", ((uint8_t *)y)[i]);
  }
  printf("\n");
}

void pprint_ss(uint64_t *x)
{
    /* for p512 we print 8 64bit little endian values as hex. */
    int ceiling = 7;
    int i;
    for(i=ceiling; i >= 0; --i){
        printf("%.16" PRIX64 "", x[i]);
    }
    printf("\n");
}

void save_file(char *file, void *buf, size_t len) {
  FILE *fhandle;
  if (file != NULL) {
    fhandle = fopen(file, "w");
    if (fhandle == NULL) {
      fprintf(stderr, "Unable to open %s\n", file);
      exit(1);
    }
    for (size_t i = 0; i < len; ++i)
      fprintf(fhandle, "%02hhx", ((uint8_t *)buf)[i]);
    fprintf(fhandle, "\n");
    fclose(fhandle);
  }
}

void error_exit(char *str) {
  fprintf(stderr, "%s\n", str);
  exit(1);
}

uint64_t read_file(const char *file, uint8_t *buf, size_t len) {
  size_t c = 0;
  FILE *fhandle;
  fhandle = fopen(file, "r");
  if (fhandle == NULL) {
    fprintf(stderr, "Unable to open %s\n", file);
    exit(3);
  }
  for (uint64_t i = 0; i < len; ++i) {
    c += fscanf(fhandle, "%02hhx", &buf[i]);
  }
  fclose(fhandle);
  return c;
}

uint64_t read_stdin(uint8_t *buf, uint64_t len) {
  uint64_t c = 0;
  for (uint64_t i = 0; i < len; ++i) {
    c += fscanf(stdin, "%02hhx", &buf[i]);
  }
  return c;
}

int main(int argc, char **argv) {
  private_key _private_key;
  public_key _public_key;
  public_key shared_secret_key;

  bzero(&_private_key, sizeof(private_key));
  bzero(&_public_key, sizeof(public_key));
  bzero(&shared_secret_key, sizeof(public_key));

  int option = 0;
  size_t verbose = 0;
  size_t generation_mode = 0;
  size_t derivation_mode = 0;
  size_t error = 0;
  bool csidh_validate = false;
  char *priv_key_file = NULL;
  char *pub_key_file = NULL;

  while ((option = getopt(argc, argv, "hvVgdp:s:")) != -1) {
    switch (option) {
    case 'V':
      fprintf(stderr, "csidh-p%i-util version: %f\n", BITS, VERSION);
      return 0;
    case 'h':
      fprintf(stderr, "csidh-p%i-util version: %f\n", BITS, VERSION);
      fprintf(stderr, "  -V: print version\n");
      fprintf(stderr, "  -verbose: increase verbosity\n");
      fprintf(stderr, "  -g: key generation mode\n");
      fprintf(stderr, "  -d: key derivation mode\n");
      fprintf(stderr, "  -p: public key file name\n");
      fprintf(stderr, "  -s: private key file name\n");
      return 0;
    case 'v':
      verbose += 1;
      break;
    case 'g':
      generation_mode = 1;
      if (derivation_mode) {
        error += 1;
      };
      break;
    case 'd':
      derivation_mode = 1;
      if (generation_mode) {
        error = 1;
      };
      break;
    case 'p':
      pub_key_file = optarg;
      if (verbose) {
        fprintf(stderr, "pub_key_file=%s\n", pub_key_file);
      };
      break;
    case 's':
      priv_key_file = optarg;
      if (verbose) {
        fprintf(stderr, "priv_key_file=%s\n", priv_key_file);
      };
      break;
    default:
      exit(1);
    }
  }

  if (error) {
    error_exit("Mutually exclusive options chosen");
  }

  if (generation_mode) {
    if (verbose) {
      fprintf(stderr, "Key generation mode\n");
    }
    csidh_private(&_private_key);
    csidh_validate = csidh(&_public_key, &base, &_private_key);
    if (!csidh_validate) {
      error_exit("csidh_validate: failed");
    }
    pprint_sk(&_private_key);
    pprint_pk(&_public_key);
    save_file(priv_key_file, &_private_key, (uint64_t) sizeof(private_key));
    save_file(pub_key_file, &_public_key,  (uint64_t) sizeof(public_key));
    return 0;
  }

  if (derivation_mode) {
    if (verbose) {
      fprintf(stderr, "DH mode\n");
    }

    if (sizeof(private_key) !=
        ((priv_key_file != NULL)
             ? read_file(priv_key_file, (uint8_t *)&_private_key,
                        (uint64_t) sizeof(private_key))
             : read_stdin((uint8_t *)&_private_key, (uint64_t) sizeof(private_key)))) {
      error_exit("Unable to read correct number of bytes for private key");
    }

    if (sizeof(public_key) !=
        ((pub_key_file != NULL)
             ? read_file(pub_key_file, (uint8_t *)&_public_key,
                         sizeof(public_key))
             : read_stdin((uint8_t *)&_public_key, sizeof(public_key)))) {
      error_exit("Unable to read correct number of bytes for public key");
    }

    csidh_validate = csidh(&shared_secret_key, &_public_key, &_private_key);
    if (!csidh_validate) {
      error_exit("csidh_validate: failed");
    }
    if (verbose) {
      pprint_sk(&_private_key);
      pprint_pk(&_public_key);
    }
    pprint_ss((uint64_t *)&shared_secret_key);
    return 0;
  }

  return 1;
}
