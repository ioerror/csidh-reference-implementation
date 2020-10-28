#ifndef CSIDH_UTIL_H
#define CSIDH_UTIL_H

#include "fp.h"
#include "csidh.h"

#define __STDC_FORMAT_MACROS
#include <inttypes.h>

#define VERSION 0.1

void pprint_pk(public_key *x);

void pprint_sk(private_key *y);

void pprint_ss(uint64_t *z);

void save_file(char *file, void *buf, uint64_t len);

void error_exit(char *str);

uint64_t read_file(const char *file, uint8_t *buf, uint64_t len);

uint64_t read_stdin(uint8_t *buf, uint64_t len);
#endif 
