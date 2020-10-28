#ifndef UINT_H
#define UINT_H

#include <stdbool.h>
#include <stdint.h>

#include "params.h"

extern const ui ui_1;

void ui_set(ui *x, uint64_t y);

bool ui_bit(ui const *x, uint64_t k);

bool ui_add3(ui *x, ui const *y, ui const *z); /* returns carry */
bool ui_sub3(ui *x, ui const *y, ui const *z); /* returns borrow */

void ui_mul3_64(ui *x, ui const *y, uint64_t z);

#endif
