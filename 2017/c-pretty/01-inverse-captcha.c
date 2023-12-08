#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "common/loadinput.h"

int main() {
  size_t i, n;
  int sum_next, sum_halfway;
  char *captcha;

  captcha = loadinput("input/input01", &n);

  while (n && isspace(captcha[n-1])) n--;

  sum_next = 0;
  sum_halfway = 0;
  for (i = 0; i < n; i++) {
    if (captcha[i] == captcha[(i + 1) % n]) {
      sum_next += captcha[i] - '0';
    }
    if (captcha[i] == captcha[(i + n/2) % n]) {
      sum_halfway += captcha[i] - '0';
    }
  }

  free(captcha);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", sum_next);
  printf("  Part 2: %d\n", sum_halfway);

  return 0;
}

