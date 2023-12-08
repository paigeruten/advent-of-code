#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "common/loadinput.h"

static int *parse_row(char **row, size_t *len) {
  char *p;
  int num, in_num;
  int *ary;
  size_t ary_size;

  *len = 0;
  ary_size = 8;
  ary = malloc(ary_size * sizeof(int));

  num = 0;
  in_num = 0;
  p = *row;
  while (1) {
    if (isdigit(*p)) {
      num = (num * 10) + (*p - '0');
      in_num = 1;
    } else {
      if (in_num) {
        if (*len >= ary_size) {
          ary_size *= 2;
          ary = realloc(ary, ary_size * sizeof(int));
        }
        ary[*len] = num;
        (*len)++;

        num = 0;
        in_num = 0;
      }

      if (*p == '\n' || *p == '\0') {
        if (*p == '\n') { p++; }
        break;
      }
    }
    p++;
  }

  *row = p;

  return ary;
}

static int checksum_minmax(const int *row, size_t len) {
  size_t i;
  int min, max;

  min = INT_MAX;
  max = INT_MIN;
  for (i = 0; i < len; i++) {
    if (row[i] < min) min = row[i];
    if (row[i] > max) max = row[i];
  }

  return max - min;
}

static int checksum_divisible(const int *row, size_t len) {
  size_t i, j;

  for (i = 0; i < len-1; i++) {
    for (j = i+1; j < len; j++) {
      if (row[i] % row[j] == 0) return row[i] / row[j];
      if (row[j] % row[i] == 0) return row[j] / row[i];
    }
  }

  return 0;
}

int main() {
  size_t len, rowlen;
  char *sheet;
  char *p;
  int sum_minmax, sum_divisible;
  int *row;

  sheet = loadinput("input/input02", &len);

  p = sheet;
  while (*p) {
    row = parse_row(&p, &rowlen);

    if (rowlen > 0) {
      sum_minmax += checksum_minmax(row, rowlen);
      sum_divisible += checksum_divisible(row, rowlen);
    }

    free(row);
  }

  printf("Solutions:\n");
  printf("  Part 1: %d\n", sum_minmax);
  printf("  Part 2: %d\n", sum_divisible);

  return 0;
}
