#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/loadinput.h"

static int *read_program(char *program, size_t *len_out) {
  size_t size, i;
  char *p;
  int *jumps;

  size = 8;
  jumps = malloc(size * sizeof(int));

  p = strtok(program, " \t\n");
  i = 0;
  while (p) {
    if (i >= size) {
      size *= 2;
      jumps = realloc(jumps, size * sizeof(int));
    }

    jumps[i] = atoi(p);
    i++;

    p = strtok(NULL, " \t\n");
  }

  *len_out = i;

  return jumps;
}

static int run_program(int *jumps, size_t num_jumps, int is_complex) {
  ssize_t i, old_i;
  int steps;

  i = 0;
  steps = 0;
  while (i >= 0 && i < num_jumps) {
    old_i = i;
    i += jumps[i];
    if (is_complex && jumps[old_i] >= 3) {
      jumps[old_i]--;
    } else {
      jumps[old_i]++;
    }
    steps++;
  }

  return steps;
}

int main() {
  size_t num_jumps;
  char *program;
  int *jumps, *jumps_copy;
  int steps_simple, steps_complex;

  program = loadinput("input/input05", NULL);
  jumps = read_program(program, &num_jumps);
  free(program);

  jumps_copy = malloc(num_jumps * sizeof(int));
  memcpy(jumps_copy, jumps, num_jumps * sizeof(int));

  steps_simple = run_program(jumps, num_jumps, 0);
  steps_complex = run_program(jumps_copy, num_jumps, 1);

  free(jumps);
  free(jumps_copy);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", steps_simple);
  printf("  Part 2: %d\n", steps_complex);

  return 0;
}
