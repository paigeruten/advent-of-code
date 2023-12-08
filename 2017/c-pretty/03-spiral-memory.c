#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "common/loadinput.h"

static int xy_to_idx(int x, int y) {
  int ring, dim, square;

  ring = abs(x);
  if (abs(y) - abs(x) > 0) {
    ring += abs(y) - abs(x);
  }

  dim = (ring * 2) + 1;
  square = dim * dim;

  if (y == ring)  return square - (dim-1)*0 - (ring - x);
  if (x == -ring) return square - (dim-1)*1 - (ring - y);
  if (y == -ring) return square - (dim-1)*2 - (ring + x);
  if (x == ring)  return square - (dim-1)*3 - (ring + y);

  return -1; // unreachable
}

static void idx_to_xy(int idx, int *x_out, int *y_out) {
  int ring, dim, square;

  dim = ceil(sqrt(idx));
  if (dim % 2 == 0) dim++;

  ring = (dim - 1) / 2;
  square = dim * dim;

  if (idx > square - (dim-1)) {
    *x_out = ring - (square - idx);
    *y_out = ring;
  } else if (idx > square - (dim-1)*2) {
    *x_out = -ring;
    *y_out = ring - (square - (dim-1) - idx);
  } else if (idx > square - (dim-1)*3) {
    *x_out = -ring + (square - (dim-1)*2 - idx);
    *y_out = -ring;
  } else {
    *x_out = ring;
    *y_out = -ring + (square - (dim-1)*3 - idx);
  }
}

static int distance_to_idx(int idx) {
  int x, y;
  idx_to_xy(idx, &x, &y);
  return abs(x) + abs(y);
}

static int sum_neighbors(const int *spiral, int idx) {
  int x, y, dx, dy, sum, neighbor;

  idx_to_xy(idx, &x, &y);

  sum = 0;
  for (dx = -1; dx <= 1; dx++) {
    for (dy = -1; dy <= 1; dy++) {
      neighbor = xy_to_idx(x + dx, y + dy);
      if (neighbor < idx) {
        sum += spiral[neighbor];
      }
    }
  }
  return sum;
}

static int generate_spiral(int upto) {
  int *spiral;
  int idx, size, final;

  size = 64;
  spiral = malloc(size * sizeof(int));
  spiral[1] = 1;

  idx = 2;
  while (1) {
    spiral[idx] = sum_neighbors(spiral, idx);

    if (spiral[idx] > upto) {
      final = spiral[idx];
      free(spiral);
      return final;
    }

    idx++;
    if (idx >= size) {
      size *= 2;
      spiral = realloc(spiral, size);
    }
  }

  return -1; // unreachable
}

int main() {
  int target = atoi(loadinput("input/input03", NULL));

  printf("Solutions:\n");
  printf("  Part 1: %d\n", distance_to_idx(target));
  printf("  Part 2: %d\n", generate_spiral(target));

  return 0;
}
